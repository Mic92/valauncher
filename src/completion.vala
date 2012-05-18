using Gee;

namespace VaLauncher {
	public class Completion : Object {
		private ArrayList <string> complist;
		private LinkedList <string> filtered;
		private ListIterator <string> iter;
		private string prefix;
		private bool inner_change;
		private Gtk.Entry entry;

		public Completion (Gtk.Entry entry) {
			this.entry = entry;
			complist = new ArrayList <string> ();
			filtered = new LinkedList <string> ();
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
						var files = yield e.next_files_async (10, Priority.DEFAULT);
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

		public void refill () {
			if (!inner_change) {
				filtered.clear ();
				prefix = entry.text;
				iter = filtered.list_iterator ();
				foreach (string s in complist) {
					if (s.has_prefix (prefix))
						filtered.add (s);
				}
			}
			inner_change = false;
		}

		public void suggest_completion () {
			if (filtered.size > 0) {
				if (iter.has_next ()) {
					iter.next ();
				} else {
					iter = filtered.list_iterator ();
					iter.next ();
				}
				inner_change = true;
				entry.text = iter.get ();
				entry.select_region (prefix.length, -1);
			}
		}
	}
}
