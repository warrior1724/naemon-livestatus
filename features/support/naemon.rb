class Naemon
  attr_accessor :brokers

  def initialize
    @config_dir = Dir.mktmpdir("naemon_test_")
    @pid = nil
    @configuration =  {
      :command_file => "naemon.cmd",
      :lock_file => "naemon.pid"
    }
    @oconf = nil
    @brokers = {}
    
  end

  def set_object_config(objectconfig)
    @configuration[:cfg_file] = "objects.cfg" 
    @oconf = objectconfig
  end

  def add_broker(broker)
    @brokers[broker.class.name.downcase.to_sym] = broker
  end

  def wait_for_start()
    sleep_time = 0.1
    slept = 0
    while slept < 5
      if @brokers.all? {|_, broker| broker.is_initialized?}
        return
      end
      sleep(sleep_time)
      slept+=sleep_time
    end
    raise "Error: Naemon, or one of its modules, failed to start!"
  end

  def start()
    naemon_cfg = File.join(@config_dir, "naemon.cfg")
    File.open(naemon_cfg, 'w') { |f|
      @configuration.each do |k, v|
        f.write("#{k.to_s}=#{v}\n")
      end

      @brokers.each do |_, broker| 
        f.write("broker_module=#{broker.broker_config}")
      end
    }

    if @configuration[:cfg_file]
      File.open(File.join(@config_dir, @configuration[:cfg_file]), 'w') { |f|
        f.write(@oconf.configfile)
      }
    end
    `naemon -d #{@config_dir}/naemon.cfg`
    self.wait_for_start
  end

  def pid()
    File.read(File.join(@config_dir, "naemon.pid")).to_i
  end

  def stop()
    `kill #{self.pid}`
    `rm -rf #{@config_dir}`
  end
end

class NaemonModule
  def broker_config
    raise "Undefined NaemonModule"
  end

  def is_initialized?()
    true
  end
end

class Livestatus < NaemonModule
  attr_accessor :last_response

  def initialize(sockpath)
    @sockpath = sockpath
  end

  def broker_config
    "/usr/lib64/naemon-livestatus/livestatus.so #{@sockpath} debug=1"
  end

  def query(q)
    cmd = "echo -e \"#{q}\"| unixcat #{@sockpath}"
    @last_response = `#{cmd}`.split("\n")
  end
  
  def is_initialized?()
    File.exists? @sockpath
  end
end
