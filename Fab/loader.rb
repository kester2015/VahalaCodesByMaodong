# $autorun
action = RBA::Action.new
action.title = "Load Script"
action.on_triggered do 
  view = RBA::Application.instance.main_window.current_view
  if !view
    raise "No view open for running the boolean script on"
    return
  end
  fn = RBA::FileDialog::get_open_file_name("Select Script", "", "All Files (*)");
  if fn.has_value?
    file_path = fn.value
    text = nil
    File.open(file_path) do |file|
      text = file.read
    end
    if !text
      RBA::MessageBox::critical("Error", "Error reading file #{file_path}", RBA::MessageBox::b_ok)
      return
    end
    begin
      eval(text)
    rescue
      RBA::MessageBox.critical("Script failed", $!.to_s, RBA::MessageBox.b_ok)
    ensure
      view.update_content
    end
  end
end

RBA::Application.instance.main_window.menu.insert_item("macros_menu.end", "script_load", action)