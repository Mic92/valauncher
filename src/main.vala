using Gtk;
using Gdk;

namespace VaLauncher {
	public class VaLauncher : Gtk.Window {
		private Entry entry;
		private Button button;
		private Completion comp;
		private History hist;
		private Gtk.Box labels;

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



			button = new Button.from_stock (Gtk.Stock.EXECUTE);

			var hbox = new Box (Orientation.HORIZONTAL, 5);
			hbox.add (entry);
			hbox.add (button);

			var label_scroll = new Gtk.Layout ();
			labels = new Gtk.Box (Orientation.HORIZONTAL, 5);
			label_scroll.put (labels, 5, 5);

			comp = new Completion (entry, labels);

			var vbox = new Box (Orientation.VERTICAL, 5);
			vbox.homogeneous = true;
			vbox.add (hbox);
			vbox.add (label_scroll);

			this.add (vbox);

			comp.fill_completion_list.begin ((obj, res) =>
				{ comp.refill ();
				  comp.fill_completion_list.end (res);
				});
		}

		private void connect_signals () {
			this.key_press_event.connect (on_key_pressed);
			entry.changed.connect (comp.refill);
			entry.move_cursor.connect (comp.refill);
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
			case "Tab":
				comp.suggest_completion ();
				return true;
			default:
				entry.secondary_icon_stock = null;
				hist.to_end ();
				break;
			}
			return false;
		}

		private void run_command () {
			try {
				string pre_cmd = comp.get_first_complete ();
				// open http url in browser
				if (pre_cmd.has_prefix ("http://")) {
					Process.spawn_command_line_async ("xdg-open " + entry.text);
				} else { // try to run command
					if (pre_cmd.has_prefix ("~/"))
						pre_cmd = Environment.get_home_dir () + pre_cmd.substring (1);
					Pid pid;
					string [] command;
					Shell.parse_argv (pre_cmd, out command);
					Process.spawn_async (null,
					                     command,
					                     null,
					                     SpawnFlags.DO_NOT_REAP_CHILD | SpawnFlags.SEARCH_PATH,
					                     null,
					                     out pid);
				}
				hist.add_entry (pre_cmd);
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
