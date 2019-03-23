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
    self
  end

  def self.create(attributes)
    self.new(attributes).save
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE dogs.id = id
      SQL

    attributes = {}
    values = DB[:conn].execute(sql)[0]
    attributes[:id] = values[0]
    attributes[:name] = values[1]
    attributes[:breed] = values[2]
    self.new(attributes)
  end

  self.find_or_create_by_name(name)
  #   sql = <<-SQL
  #     SELECT * FROM dogs
  #     WHERE dogs.name = name;
  #     SQL
  #
  #   if !DB[:conn].execute(sql)
  #     self.new.send("#{name}=", name)
  #   end
  end


end
