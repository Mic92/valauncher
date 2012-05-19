using Gee;

namespace VaLauncher {
	public class Completion : Object {
		private ArrayList <string> complist;
		private LinkedList <string> filtered;
		private string prefix;
		private bool inner_change;
		private Gtk.Entry entry;
		private LinkedList <Gtk.Label> labels;
		private Gtk.Box labels_box;
		// Blame you, Vala iterators!
		private int index = 0;

		public Completion (Gtk.Entry entry, Gtk.Box lbox) {
			this.entry = entry;
			complist = new ArrayList <string> ();
			filtered = new LinkedList <string> ();
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
							complist.add (info.get_name ());
						}
					}
				} catch (Error e) {
					stderr.printf ("While parsing %s: %s\n", pdir, e.message);
				}
			}
		}

		public void run () {
			fill_completion_list.begin ((obj, res) =>
				{
				  complist.sort ((a, b) => { return ((string)a).collate((string)b); });
				  refill ();
				  fill_completion_list.end (res);
				});
		}

		public void refill () {
			if (!inner_change) {
				foreach (Gtk.Label lbl in labels) {
					labels_box.remove (lbl);
				}
				filtered.clear ();
				labels.clear ();
				index = 0;
				prefix = entry.text;
				foreach (string s in complist) {
					if (s.has_prefix (prefix))
						filtered.add (s);
				}

				for (int i = 0; i < filtered.size; i++) {
					labels.add (new Gtk.Label (filtered[i]));
					labels_box.add (labels[i]);
					if (i == 20)
						break;
				}
				labels_box.show_all ();
				if (filtered.size > 0) {
					labels[index].use_markup = true;
					labels[index].set_markup (
						"<span color=\"white\" bgcolor=\"blue\">" + filtered[index] + "</span>");
				}
			}
			inner_change = false;
		}

		public void suggest_completion () {
			if (filtered.size > 0) {
				labels[index].use_markup = false;
				labels[index].label = filtered[index];
				if (index < labels.size - 1) {
					index++;
				} else {
					index = 0;
				}
				inner_change = true;
				entry.text = filtered [index];
				entry.select_region (prefix.length, -1);
				labels[index].use_markup = true;
				labels[index].set_markup (
					"<span color=\"white\" bgcolor=\"blue\">" + entry.text + "</span>");
			}
		}

		public bool contains (string entry) {
			return complist.contains (entry);
		}

		public string get_first_complete () {
			if (!filtered.contains(entry.text) && filtered.size > 0)
				return filtered[0];
			return entry.text;
		}
	}
}
