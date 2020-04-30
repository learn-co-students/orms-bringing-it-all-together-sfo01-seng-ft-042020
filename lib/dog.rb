class Dog
  attr_accessor :name, :breed, :id
  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table 
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS 
    dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs;")
  end

  def save
    if self.id
      self.update
    else
      
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?,?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(attributes)
    new_dog = self.new(attributes)
    new_dog.save
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(dog_id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL
    result = DB[:conn].execute(sql, dog_id).flatten
    self.new_from_db(result)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      AND breed = ?
      LIMIT 1
    SQL
    # binding.pry
    dog = DB[:conn].execute(sql, name, breed)
    if !dog.empty?
      dog_row = dog[0]
      dog = self.new(id: dog_row[0], name: dog_row[1], breed: dog_row[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name).flatten
    dog = self.new_from_db(row)
    dog
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end