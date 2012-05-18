using Gee;

namespace VaLauncher {
	public class History : Object {
		private LinkedList <string> hlist;
		// Unfortunately, iterators in Vala Gee are unstable at this moment.
		private int index = 0;
		private bool active = true;

		public History () {
			hlist = new LinkedList <string> ();
			try {
				var histdir = File.new_for_path (Environment.get_user_cache_dir () + "/valauncher");
				if (!histdir.query_exists ())
					histdir.make_directory_with_parents ();

				var histfile = histdir.get_child ("history");
				if (!histfile.query_exists ())
					histfile.create (FileCreateFlags.NONE);

				var dis = new DataInputStream (histfile.read ());
				string line;
				while ((line = dis.read_line (null)) != null) {
					hlist.add (line);
				}
				hlist.add ("");
				index = hlist.size - 1;
			} catch (Error e) {
				if (e is IOError.NOT_SUPPORTED) {
					stderr.printf (e.message + "\n");
				}
				active = false;
			}
		}

		// Add history entry after successful execution
		public void add_entry (string entry_text) {
			hlist[hlist.size-1] = entry_text;
		}

		public void write_to_file () {
			if (!active)
				return;
			try {
				var histfile = File.new_for_path (Environment.get_user_cache_dir () + "/valauncher/history");
				if (histfile.query_exists ()) {
					histfile.delete ();
				}
				var dos = new DataOutputStream (histfile.create (FileCreateFlags.REPLACE_DESTINATION));

				// Remove repeated lines
				for (int i = 0; i < hlist.size-1; i++) {
					if (hlist[i] != "" && hlist[i] != hlist[i+1])
						dos.put_string (hlist[i] + "\n");
				}
				dos.put_string (hlist[hlist.size-1] + "\n");

			} catch (Error e) {
				stderr.printf ("%s\n", e.message);
			}
		}

		public string before (string current_text) {
			if (!active)
				return "";

			if (index == (hlist.size - 1) && current_text != hlist [index])
				hlist[index] = current_text;
			if (index > 0)
				index--;
			return hlist [index];
		}

		public string after (string current_text) {
			if (!active)
				return "";

			if (index == (hlist.size - 1) && current_text != hlist [index])
				hlist[index] = current_text;
			if (index < hlist.size - 1)
				index++;
			return hlist [index];
		}

		public void to_end () {
			index = hlist.size-1;
		}
	}
}
