using Gee;

namespace VaLauncher {
	public class Completion : Object {
		private TreeSet <string> compset;
		private ArrayList <string> filtered;
		private string prefix;
		private bool inner_change;
		private Gtk.Entry entry;
		private LinkedList <Gtk.Label> labels;
		private Gtk.Box labels_box;
		// Blame you, Vala iterators!
		private int index = 0;

		public Completion (Gtk.Entry entry, Gtk.Box lbox) {
			this.entry = entry;
			compset = new TreeSet <string> ((a, b) => { return ((string)a).collate((string)b); });
			filtered = new ArrayList <string> ();
			labels = new LinkedList <Gtk.Label> ();
			labels_box = lbox;
		}

		public async void fill_completion_list () {
			string [] plist = Environment.get_variable ("PATH").split (":");
			foreach (string pdir in plist) {
				var dir = File.new_for_path (pdir);
				try {
					// asynchronous call to get directory enumerator.
					var e = yield dir.enumerate_children_async
						(FileAttribute.STANDARD_NAME, 0, Priority.DEFAULT);
					while (true) {
						// async call to get entries
						var files = yield e.next_files_async (100, Priority.DEFAULT);
						if (files == null) {
							break;
						}
						// append files to the list
						foreach (var info in files) {
							compset.add (info.get_name ());
						}
					}
				} catch (Error e) {
					stderr.printf ("While parsing %s: %s\n", pdir, e.message);
				}
			}
		}

		public void run () {
			// start asynchronous filling
			fill_completion_list.begin ((obj, res) =>
				{
					// When filling is complete...
					refill ();
					fill_completion_list.end (res);
				});
		}

		public void refill () {
			// To prevent updating prefix after "Tab"
			if (!inner_change) {
				foreach (Gtk.Label lbl in labels) {
					labels_box.remove (lbl);
				}
				filtered.clear ();
				labels.clear ();
				index = 0;
				prefix = entry.text;

				int i = 0;
				if (prefix == null || prefix.length == 0) {
					foreach (string s in compset) {
						filtered.add (s);
						labels.add (new Gtk.Label (filtered[i]));
						labels_box.add (labels[i]);
						i++;
						if (i == 31) // Too much will hang application...
							break;
					}
				} else {
					foreach (string s in compset.tail_set(prefix)) {
						if (s.has_prefix (prefix)) {
							filtered.add (s);
							labels.add (new Gtk.Label (filtered[i]));
							labels_box.add (labels[i]);
							i++;
							if (i == 31) // Too much will hang application...
								break;
						}
					}
				}

				labels_box.show_all ();
				// Highlight first label
				if (filtered.size > 0) {
					highlight_label (index);
				}
			}
			inner_change = false;
		}

		public void suggest_completion (bool forward) {
			if (filtered.size > 0) {
				// Unhighlight previous label
				labels[index].use_markup = false;
				labels[index].label = filtered[index];
				// Cycle scrolling
				if (forward) {
					if (index < labels.size - 1) {
						index++;
					} else {
						index = 0;
					}
				} else {
					if (index > 0) {
						index--;
					} else {
						index = labels.size - 1;
					}
				}
				inner_change = true;
				entry.text = filtered [index];
				// Select suggested text
				entry.select_region (prefix.length, -1);
				// Highlight current label
				highlight_label (index);
			}
		}

		private void highlight_label (int index) {
			labels[index].use_markup = true;
			var style = Gtk.rc_get_style(labels[index]);
			Gdk.Color fg_color, bg_color;
			if (!style.lookup_color("theme_selected_fg_color", out fg_color)) {
				Gdk.Color.parse("white", out fg_color);
			};
			if (!style.lookup_color("theme_selected_bg_color", out bg_color)) {
				Gdk.Color.parse("blue", out bg_color);
			};
			labels[index].set_markup (
				@"<span color=\"$(fg_color.to_string())\" bgcolor=\"$(bg_color.to_string())\">$(filtered[index])</span>");
			// Emit signal to update labels_box position.
			Gtk.Allocation tmp_alloc;
			labels[index].get_allocation (out tmp_alloc);
			label_selected (tmp_alloc.x, tmp_alloc.width);
		}

		public bool contains (string entry) {
			return compset.contains (entry);
		}

		// Gives ability to launch application without typing the whole name of it.
		public string get_first_complete () {
			if (!filtered.contains(entry.text) && filtered.size > 0)
				return filtered[0];
			return entry.text;
		}

		// Signall emitted when some of the labels get selected
		public signal void label_selected (int x, int width);
	}
}
