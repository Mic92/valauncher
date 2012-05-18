using Gtk;

namespace VaLauncher {
	public class Completion : EntryCompletion {
		private ListStore complist;

		public Completion () {
			complist = new ListStore (1, typeof(string));
			this.model = complist;
			this.text_column = 0;
			this.inline_completion = true;
			this.inline_selection = true;
			this.popup_completion = false;
		}

		public async void fill_completion_list () {
			string [] plist = Environment.get_variable ("PATH").split (":");
			TreeIter iter;
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
							complist.append (out iter);
							complist.set (iter, 0, info.get_name ());
						}
					}
				} catch (Error e) {
					stderr.printf ("While parsing %s: %s\n", pdir, e.message);
				}
			}
		}
	}
}
