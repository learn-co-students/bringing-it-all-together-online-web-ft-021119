class Dog
  attr_accessor :id, :name, :breed


  def initialize(attributes)
    attributes.each {|key, value| self.send(("#{key}="), value)}
    self.id ||= nil
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE if NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
      SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE DOGS")
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(attributes)
    self.new(attributes).save
  end

  def self.new_from_db(row)
    attributes = {
      :id => row[0],
      :name => row[1],
      :breed => row[2]
    }
    self.new(attributes)
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE dogs.id = ?
      SQL

    row = DB[:conn].execute(sql, id)[0]
    self.new_from_db(row)
  end

    def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ? AND breed = ?
      SQL
    dog = DB[:conn].execute(sql, name, breed).first

    if dog
      new_dog = self.new_from_db(dog)
    else
      new_dog = self.create({:name => name, :breed => breed})
    end
    new_dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE dogs.name = ?
      SQL

    row = DB[:conn].execute(sql, name)[0]
    self.new_from_db(row)
  end

  def update

    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
      SQL

    updated_row = DB[:conn].execute(sql, self.name, self.breed, self.id)
  end



end
