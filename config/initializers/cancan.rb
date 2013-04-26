# Monkey patching CanCan bug https://github.com/ryanb/cancan/issues/663.
# ToDo: The bug is fixed in 2.0 branch if CanCan. If updated, remove this file.
module CanCan
  class ControllerResource

    protected

    def namespace
      @params[:controller].split(/::|\//)[0..-2]
    end
  end
end