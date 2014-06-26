module RPS
  class DB
    def initialize(dbname = 'rps')
      @conn = PG.connect(host: 'localhost', dbname: dbname)

      build_tables
    end

    def build_tables
      @conn.exec(%Q[
        CREATE TABLE IF NOT EXISTS players(
          id serial NOT NULL PRIMARY KEY,
          username text NOT NULL UNIQUE,
          name text,
          pwd text NOT NULL
        )])

      @conn.exec(%Q[
        CREATE TABLE IF NOT EXISTS sessions(
          id serial NOT NULL PRIMARY KEY,
          session_id text NOT NULL UNIQUE,
          player_id integer REFERENCES players(id)
        )])

      @conn.exec(%Q[
        CREATE TABLE IF NOT EXISTS matches(
          id serial NOT NULL PRIMARY KEY,
          player_1_id integer REFERENCES players(id),
          player_2_id integer REFERENCES players(id),
          started_at timestamp NOT NULL DEFAULT current_timestamp,
          completed_at timestamp
        )])

      @conn.exec(%Q[
        CREATE TABLE IF NOT EXISTS games(
          id serial NOT NULL PRIMARY KEY,
          match_id integer REFERENCES matches(id),
          started_at timestamp NOT NULL DEFAULT current_timestamp,
          completed_at timestamp
        )])

      @conn.exec(%Q[
        CREATE TABLE IF NOT EXISTS moves(
          id serial NOT NULL PRIMARY KEY,
          game_id integer REFERENCES games(id),
          player_id integer REFERENCES players(id),
          name text NOT NULL
        )])
    end

    ### CREATE ###

    def create(sklass, args)
      keys   = args.keys.join(", ")
      values = args.values.map { |s| "'#{s}'" }.join(', ')

      command = %Q[ INSERT INTO #{sklass} (#{keys})
                    VALUES (#{values})
                    returning *; ]

      execute_the(command, sklass)
    end

    ### READ / FIND ###
    def find(sklass, args)
      command = "SELECT * FROM #{sklass}"

      unless args.empty?
        command += " WHERE "
        args_ary = [ ]
        args.each do |k,v|
          args_ary.push("#{k} = #{v}")
        end

        command += args_ary.join(" AND ")
      end

      command += ";"

      execute_the(command, sklass)
    end

    ### UPDATE ###

    def update(sklass, id, args)
      keys   = args.keys.join(", ")
      values = args.values.map { |s| "'#{s}'" }.join(', ')

      command = %Q[ UPDATE #{sklass}
                    SET (#{keys}) = (#{values})
                    WHERE id = #{id}
                    returning *; ]

      execute_the(command, sklass)
    end

    ### DELETE ###

    def delete(sklass, id)
      command = %Q[ DELETE FROM #{sklass}
                    WHERE id = #{id}
                    returning *; ]

      execute_the(command, sklass)
    end

    private

    def klass(sklass)
      {
        'sessions' => RPS::Session,
        'players'  => RPS::Player,
        'matches'  => RPS::Match,
        'games'    => RPS::Game,
        'moves'    => RPS::Move
      }[sklass]
    end

    def execute_the(command, sklass)
      results = @conn.exec(command)

      parsed_results = parse_the(results)

      parsed_results.map do |obj_hash|
        klass(sklass).send(:new, obj_hash)
      end
    end

    def parse_the(results)
      presults = [ ]

      results.each do |result|
        presult = result.inject({}){|hash,(k,v)| hash[k.to_sym] = v; hash}

        presult[:id          ] = presult[:id         ].to_i
        presult[:player_id   ] = presult[:player_id  ].to_i if presult[:player_id]
        presult[:player_1_id ] = presult[:player_1_id].to_i if presult[:player_1_id]
        presult[:player_2_id ] = presult[:player_2_id].to_i if presult[:player_2_id]
        presult[:game_id     ] = presult[:game_id    ].to_i if presult[:game_id]
        presult[:match_id    ] = presult[:match_id   ].to_i if presult[:match_id]
        presult[:started_at  ] = Time.parse( presult[:started_at] ) if presult[:started_at]
        presult[:completed_at] = Time.parse( presult[:completed_at] ) if presult[:completed_at]

        presults << presult
      end

      presults
    end

    def conn
      @conn
    end

    def conn=(conn)
      @conn = conn
    end

    def drop_tables
      @conn.exec(%Q[ DROP TABLE IF EXISTS moves CASCADE; ])
      @conn.exec(%Q[ DROP TABLE IF EXISTS games CASCADE; ])
      @conn.exec(%Q[ DROP TABLE IF EXISTS matches CASCADE; ])
      @conn.exec(%Q[ DROP TABLE IF EXISTS sessions CASCADE; ])
      @conn.exec(%Q[ DROP TABLE IF EXISTS players CASCADE; ])
    end
  end

  def self.db
    @_db_singleton ||= DB.new
  end
end
