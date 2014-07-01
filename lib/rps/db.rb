module RPS
  class DB
    def initialize(dbname = 'rps')
      @conn = PG.connect(host: 'localhost', dbname: dbname)

      # drop_tables
      # build_tables
    end

    def build_tables
      @conn.exec(%Q[
        CREATE TABLE IF NOT EXISTS players(
          player_id serial NOT NULL PRIMARY KEY,
          username text NOT NULL UNIQUE,
          name text,
          pwd text NOT NULL
        );])

      @conn.exec(%Q[
        CREATE TABLE IF NOT EXISTS sessions(
          id serial NOT NULL PRIMARY KEY,
          session_id text NOT NULL UNIQUE,
          player_id integer REFERENCES players(player_id),
          started_at timestamp NOT NULL DEFAULT current_timestamp
        );])

      @conn.exec(%Q[
        CREATE TABLE IF NOT EXISTS matches(
          match_id serial NOT NULL PRIMARY KEY,
          started_at timestamp,
          completed_at timestamp
        );])

      @conn.exec(%Q[
        CREATE TABLE IF NOT EXISTS playermatches(
          id serial NOT NULL PRIMARY KEY,
          match_id integer REFERENCES matches(match_id),
          player_id integer REFERENCES players(player_id)
        );])

      @conn.exec(%Q[
        CREATE TABLE IF NOT EXISTS games(
          game_id serial NOT NULL PRIMARY KEY,
          match_id integer REFERENCES matches(match_id),
          started_at timestamp NOT NULL DEFAULT current_timestamp,
          completed_at timestamp
        );])

      @conn.exec(%Q[
        CREATE TABLE IF NOT EXISTS moves(
          move_id serial NOT NULL PRIMARY KEY,
          game_id integer REFERENCES games(game_id),
          player_id integer REFERENCES players(player_id),
          action text NOT NULL
        );])
    end

    ### CREATE ###

    def create(sklass, args)
      # args.each do |k,v|
      #   if v == nil
      #     args[k] = 'NULL'
      #   end
      # end

      keys   = args.keys.join(", ")
      values = args.values.map { |s| "'#{s}'" }.join(', ')

      if keys.empty?
        command = %Q[ INSERT INTO #{sklass}
                      DEFAULT VALUES
                      returning *; ]
      else
        command = %Q[ INSERT INTO #{sklass} (#{keys})
                      VALUES (#{values})
                      returning *; ]
      end

      execute_the(command, sklass)
    end

    ### READ / FIND ###
    def find(sklass, args)
      command = "SELECT * FROM #{sklass}"

      unless args.empty?
        command += " WHERE "
        args_ary = [ ]
        args.each do |k,v|
          if v.nil?
            args_ary.push("#{k} IS NULL")
          else
            args_ary.push("#{k} = '#{v}'")
          end
        end

        command += args_ary.join(" AND ")
      end

      command += ";"

      execute_the(command, sklass)
    end

    def find_playermatches(sklass, args)
      command = "SELECT * FROM #{sklass}"

      unless args.empty?
        command += " WHERE "
        args_ary = [ ]
        args.each do |k,v|
          if v.nil?
            args_ary.push("#{k} IS NULL")
          else
            args_ary.push("#{k} = #{v}")
          end
        end

        command += args_ary.join(" AND ")
      end

      command += ";"

      execute_the(command, sklass)
    end

    def get_match_by(sklass, args)
      command = "SELECT * FROM matches, playermatches WHERE matches.match_id = playermatches.match_id AND matches.match_id = #{args['match_id']} AND player_id = #{args['player_id']};"

      # unless args.empty?
      #   command += " WHERE "
      #   args_ary = [ ]
      #   args.each do |k,v|
      #     if v.nil?
      #       args_ary.push("#{k} IS NULL")
      #     else
      #       args_ary.push("#{k} = #{v}")
      #     end
      #   end

      #   command += args_ary.join(" AND ")
      # end

      # command += ";"

      execute_the(command, sklass)
    end


    ### UPDATE ###

    def update(sklass, id_array, args)
      keys   = args.keys.join(", ")
      values = args.values.map { |s| "'#{s}'" }.join(', ')

      command = %Q[ UPDATE #{sklass}
                    SET (#{keys}) = (#{values})
                    WHERE #{id_array[0]} = '#{id_array[1]}'
                    returning *; ]

      execute_the(command, sklass)
    end

    ### DELETE ###

    def delete(sklass, id_array)
      command = %Q[ DELETE FROM #{sklass}
                    WHERE #{id_array[0]} = '#{id_array[1]}'
                    returning *; ]

      execute_the(command, sklass)
    end

    def create_playermatches(sklass,args)
      keys   = args.keys.join(", ")
      values = args.values.map { |s| "'#{s}'" }.join(', ')

      command = %Q[ INSERT INTO #{sklass} (#{keys})
                    VALUES (#{values})
                    returning *; ]

      results = @conn.exec(command)

      parsed_results = parse_the(results)
    end

    private

    def klass(sklass)
      this_klass = sklass.split(',').first
      {
        'sessions' => RPS::Session,
        'players'  => RPS::Player,
        'matches'  => RPS::Match,
        'games'    => RPS::Game,
        'moves'    => RPS::Move
      }[this_klass]
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
        presult[:match_id    ] = presult[:match_id   ].to_i if presult[:match_id]
        presult[:game_id     ] = presult[:game_id    ].to_i if presult[:game_id]
        presult[:move_id     ] = presult[:move_id    ].to_i if presult[:move_id]
        if presult[:started_at]
          presult[:started_at] = Time.parse( presult[:started_at] )
        end
        if presult[:completed_at]
          presult[:completed_at] = Time.parse( presult[:completed_at] )
        end
        presult[:action] = presult[:action].to_sym if presult[:action]

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
      @conn.exec(%Q[ DROP TABLE IF EXISTS playermatches CASCADE; ])
      @conn.exec(%Q[ DROP TABLE IF EXISTS matches CASCADE; ])
      @conn.exec(%Q[ DROP TABLE IF EXISTS sessions CASCADE; ])
      @conn.exec(%Q[ DROP TABLE IF EXISTS players CASCADE; ])
    end
  end

  def self.db
    @_db_singleton ||= DB.new
  end
end
