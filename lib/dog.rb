require 'pry'

class Dog
  attr_accessor :id, :name, :breed


  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end


  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL

    DB[:conn].execute(sql)
  end


  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

#SAVE - COMPLETE
  def save
    if self.id
      self.update
      self
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?,?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

#CREATE - COMPLETE
  def self.create(attribute_hash)
    new_dog = Dog.new(attribute_hash)
    new_dog.save
    new_dog
  end

#FIND BY ID - COMPLETE
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    selected_dog_data = DB[:conn].execute(sql, id).flatten
    id = selected_dog_data[0]
    name = selected_dog_data[1]
    breed = selected_dog_data[2]
    Dog.new(id: id, name: name, breed: breed)
  end

#FIND OR CREATE BY - COMPLETE
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty? #found dog
      dog_data = dog.flatten
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else #could not find dog
      self.create(name: name, breed: breed)
    end
  end

#NEW FROM DATABASE - COMPLETE
  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]

    new_dog = Dog.new(id: id, name: name, breed: breed)
    new_dog
  end


#FIND BY NAME - COMPLETE
    def self.find_by_name(name)
      sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
      SQL

      selected_dog_data = DB[:conn].execute(sql, name).flatten
      id = selected_dog_data[0]
      name = selected_dog_data[1]
      breed = selected_dog_data[2]

      Dog.new(id: id, name: name, breed: breed)
    end

#UPDATE
    def update
      sql = <<-SQL
        UPDATE dogs
        SET name = (?), breed = (?)
        WHERE id = (?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed, self.id)

      #sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      #DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end
