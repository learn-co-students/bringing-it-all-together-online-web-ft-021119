require 'pry'

class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def self.new_from_db(array)
    dog = self.new(name: array[1], breed: array[2], id: array[0])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    temp = DB[:conn].execute(sql, name).first
    self.new(name: temp[1], breed: temp[2], id: temp[0])
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten.first
      self
    end
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(number)
    sql = "SELECT * FROM dogs WHERE id = ?"
    #binding.pry
    temp = DB[:conn].execute(sql, number).flatten
    self.new_from_db(temp)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_temp = dog.first
      dog = Dog.new(name: dog_temp[1], breed: dog_temp[2], id: dog_temp[0])
    else
      dog = Dog.create(name: name, breed: breed)
    end
    dog
  end
end
