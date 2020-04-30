class Dog
    attr_accessor :name, :breed, :id

    def initialize(attr)
        attr.each {|k, v| self.send("#{k}=", v)}
    end

    def save
        if @id
            update
        else
            sql = <<-SQL
            INSERT INTO dogs (name, breed) VALUES (?, ?)
            SQL
            params = [@name, @breed]
            DB[:conn].execute(sql, params)
            @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
            self
        end
    end

    def update
        params = [@name, @breed, @id]
        sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL
        DB[:conn].execute(sql, params)
    end

    def self.create(attr)
        Dog.new(attr).save
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
        SQL
        DB[:conn].execute(sql)
    end

    def self.new_from_db(row)
        Dog.new(Hash[[:id, :name, :breed].zip(row)])
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
        SQL
        new_from_db(DB[:conn].execute(sql, id)[0])
    end

    def self.find_or_create_by(attr)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ? AND breed = ?
        SQL
        hit = DB[:conn].execute(sql, attr[:name], attr[:breed])[0]
        if hit.nil?
            create(attr)
        else
            new_from_db(hit)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ?
        SQL
        new_from_db(DB[:conn].execute(sql, name)[0])
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end
end