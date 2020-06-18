class Dog
  attr_accessor :name, :breed, :id

  def initialize(args)
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
    # @name = name
    # @breed = breed
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
      DROP TABLE dogs;
    SQL
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    # binding.pry
    dog = self.new(row)
    dog.id = row[0]
    dog.name = row[1]
    dog.breed = row[2]
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql,self.name,self.breed,self.id)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?,?);
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(row)
    dog = Dog.new(row)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL
    DB[:conn].execute(sql,id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    args = {name: name,breed: breed}
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_id = dog.flatten[0]
      dog = Dog.new(args)
      dog.id = dog_id
       # Dog does not have an id (which should be 1) #<Dog:0x0000000001a50608 @breed="cockapoo", @name="teddy">
    else
      dog = self.create(args) # Dog(<Dog OBJ @breed="irish setter", @id=3, @name="teddy">)has an id = 3
# binding.pry
    end
# binding.pry
    dog #<Dog:0x0000000001a50608 @breed="cockapoo", @name="teddy">
  end
end
