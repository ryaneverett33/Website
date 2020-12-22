module Jekyll
  class Helpers
    # Method to convert string to bool (which is dumb ruby doesn't have this in the first place)
    # https://stackoverflow.com/a/36229316
    def self.parse_bool(str)
      str.to_s.downcase == "true"
    end
    def self.resolve_context(context, arr, index)
      tmp = context[arr[index]]
      if tmp == nil
        return arr[index]
      end
      return tmp
    end
  end
end
