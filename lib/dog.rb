class Dog

  attr_accessor :name, :breed, :id


  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end


  def self.create_table
    self.drop_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
    self
  end

  def self.create(data)
    new = self.new(data)
    new.save
    new
  end

  def self.new_from_db(row)
    # binding.pry
    self.new(id:row[0], name:row[1], breed:row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?;
    SQL
    Dog.new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL
    Dog.new_from_db(DB[:conn].execute(sql, id)[0])
  end

  def self.all
    sql = <<-SQL
      SELECT *
      FROM dogs
    SQL
    DB[:conn].execute(sql).collect {|dogs| Dog.new_from_db(dogs)}
  end

  def self.find_or_create_by(data)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?;
    SQL
    # binding.pry
    dog = DB[:conn].execute(sql, data[:name], data[:breed])
    # binding.pry
    !dog.empty? ? dog = Dog.new_from_db(dog[0]) : dog = Dog.create(data)
    dog
  end

  def self.find_or_create_by(data)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?;
    SQL
    dog = DB[:conn].execute(sql, data[:name], data[:breed])
    dog.empty? ? Dog.create(data) : Dog.new_from_db(dog[0])
  end


end
