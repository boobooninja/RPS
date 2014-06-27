module RPS
  class DeleteSession
    def self.run(params) # :session_id => "session_id"
      session = RPS.db.delete('sessions', [ :session_id, params[:session_id] ]).first

      if session
        { :success? => true, :session => session, :errors => [] }
      else # return a error
        { :success? => false, :errors => ['invalid session'] }
      end
    end
  end
end
