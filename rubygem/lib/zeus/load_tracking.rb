module Zeus
  class LoadTracking
    class << self

      def features_loaded_by(&block)
        old_features = all_features()
        yield
        new_features = all_features() - old_features
        return new_features
      end

      def all_features
        untracked = defined?($untracked_features) ? $untracked_features : []
        $LOADED_FEATURES + untracked
      end

      def add_feature(file)
        path = if File.exist?(File.expand_path(file))
          File.expand_path(file)
        else
          find_in_load_path(file)
        end
        Zeus.add_extra_feature(path) if path
      end

      private

      def find_in_load_path(file)
        $LOAD_PATH.map { |path| "#{path}/#{file}" }.detect{ |file| File.exist? file }
      end
    end
  end
end

module Kernel

  def load(file, *a)
    Kernel.load(file, *a)
  end

  class << self
    alias_method :__load_without_zeus, :load
    def load(file, *a)
      Zeus::LoadTracking.add_feature(file)
      __load_without_zeus(file, *a)
    end
  end
end
