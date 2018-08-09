ActiveAdmin.register Role do
  form do |f|
    f.inputs "Role" do
      f.input :name
    end
    f.buttons
  end
end

