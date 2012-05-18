using Gtk;
using Gdk;

namespace VaLauncher {
	public class VaLauncher : Gtk.Window {
		private Entry entry;
		private Button button;
		private Completion comp;
		private History hist;

		public VaLauncher () {
			title = "valauncher";
			window_position = WindowPosition.CENTER;
			resizable = false;
			decorated = false;
			border_width = 5;

			hist = new History ();

			create_layout ();
			connect_signals ();
		}

		private void create_layout () {
			entry = new Entry ();
			entry.width_chars = 80;
			entry.placeholder_text = "Enter application name here...";

			comp = new Completion ();
			entry.completion = comp;

			button = new Button.from_stock (Gtk.Stock.EXECUTE);

			var hbox = new Box (Orientation.HORIZONTAL, 5);
			hbox.add (entry);
			hbox.add (button);

			this.add (hbox);

			comp.fill_completion_list.begin ();
		}

		private void connect_signals () {
			this.key_press_event.connect (on_key_pressed);
			button.clicked.connect (run_command);
			this.destroy.connect (Gtk.main_quit);
		}

		private bool on_key_pressed (Widget source, EventKey key) {
			switch (keyval_name (key.keyval)) {
			case "Return":
				run_command ();
				break;
			case "Escape":
				Gtk.main_quit ();
				break;
			case "Up":
				entry.text = hist.before (entry.text);
				entry.select_region (0, -1);
				break;
			case "Down":
				entry.text = hist.after (entry.text);
				entry.select_region (0, -1);
				break;
			default:
				entry.secondary_icon_stock = null;
				hist.to_end ();
				break;
			}
			return false;
		}

		private void run_command () {
			try {
				Pid pid;
				string [] command;
				Shell.parse_argv (entry.text, out command);
				Process.spawn_async (null,
									 command,
									 null,
									 SpawnFlags.DO_NOT_REAP_CHILD | SpawnFlags.SEARCH_PATH,
									 null,
									 out pid);

				hist.add_entry (entry.text);
				hist.write_to_file ();
				Gtk.main_quit ();
			} catch (Error e) {
				entry.secondary_icon_stock = Gtk.Stock.DIALOG_ERROR;
				entry.secondary_icon_tooltip_text = e.message;
			}
		}

		static int main (string [] args) {
			Gtk.init (ref args);

			var vl = new VaLauncher ();
			vl.show_all ();

			Gtk.main ();
			return 0;
		}
	}
}
