class Bolt::UI
  def initialize
    @progress = ProgressBar.create(:format => '%a %B %p%% %t', :autostart => false, :autofinish => false)
  end

  def notify(type, value = nil)
    case type
    when :start
      @progress.total = value
      @progress.start
    when :done
      @progress.finish
    else
      @progress.increment
    end
  end
end
