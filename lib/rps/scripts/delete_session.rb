module RPS
  class DeleteSession
    def self.run(params) # :session_id => "session_id"
      session = RPS.db.delete('sessions', params[:session_id])

      if session
        { :success? => true, :session => session }
      else # return a error
        { :success? => false, :error => :invalid_session }
      end
    end
  end
end
