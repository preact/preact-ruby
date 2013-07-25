module Preact
	class AccountEvent < Event

    def as_json(options={})
      super(options).merge({
        :klass => "accountevent"
      })
    end

	end

end