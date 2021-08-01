using Gtk;
using Gdk;

namespace VaLauncher {
  public class VaLauncher : Gtk.Window {
    private Gtk.Entry entry;
    private Gtk.Button button;
    private Completion comp;
    private History hist;
    private Gtk.Box labels;
    // Scrollable area of labels
    private Gtk.Layout label_scroll;

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

      button = new Button.from_icon_name ("system-run", Gtk.IconSize.SMALL_TOOLBAR);

      var hbox = new Box (Orientation.HORIZONTAL, 5);
      hbox.add (entry);
      hbox.add (button);

      label_scroll = new Gtk.Layout ();
      labels = new Gtk.Box (Orientation.HORIZONTAL, 5);
      label_scroll.put (labels, 5, 5);

      comp = new Completion (entry, labels);
      comp.run ();

      var vbox = new Box (Orientation.VERTICAL, 5);
      vbox.homogeneous = true;
      vbox.add (hbox);
      vbox.add (label_scroll);

      this.add (vbox);
    }

    private void connect_signals () {
      this.key_press_event.connect (on_key_pressed);
      entry.changed.connect (comp.refill);
      entry.move_cursor.connect (comp.refill);
      button.clicked.connect (run_command);
      comp.label_selected.connect (scroll_labels_box);
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
        comp.suggest_completion (true);
        return true;
      case "ISO_Left_Tab":
        comp.suggest_completion (false);
        return true;
      default:
        entry.secondary_icon_name = null;
        hist.to_end ();
        break;
      }
      return false;
    }

    private void run_command () {
      try {
        string pre_cmd = comp.get_first_complete ();
        // open http url in browser
        if (pre_cmd.has_prefix ("~/"))
          pre_cmd = Environment.get_home_dir () + pre_cmd.substring (1);
        if (pre_cmd.has_prefix ("http://") || pre_cmd.has_suffix("/")) {
          Process.spawn_command_line_async ("xdg-open " + pre_cmd);
        } else { // try to run command
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
        entry.secondary_icon_name = "dialog-error";
        entry.secondary_icon_tooltip_text = e.message;
      }
    }

    private void scroll_labels_box (int x, int width)
    {
      // temporary var to get widget's position and size
      Gtk.Allocation tmp_alloc;

      // width of scrollable area
      label_scroll.get_allocation (out tmp_alloc);
      var scrl_width = tmp_alloc.width;

      // x of labels box
      labels.get_allocation (out tmp_alloc);
      var lbls_x = tmp_alloc.x;

      // If label is outside the window, scroll to that position
      if (x + width > scrl_width) {
        // Move forward
        label_scroll.move (labels, scrl_width+lbls_x-(x+width)-5, 5);
      } else if (lbls_x < 0 && x < 0) {
        // Move backward
        label_scroll.move (labels, lbls_x-x+5, 5);
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
