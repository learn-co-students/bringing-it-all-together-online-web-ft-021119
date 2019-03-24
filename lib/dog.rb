require 'pry'
class Dog
@@all =[]
attr_accessor :name, :breed
attr_reader :id
		def initialize(name:, breed:, id:  nil)
			@name  = name
			@breed = breed
			@id = id 
      @@all << self
   
    
		end
   
		def self.create_table
       sql = <<-SQL
       	CREATE TABLE IF NOT EXISTS dogs (
       	id INTEGER PRIMARY KEY,
       	name TEXT,
       	breed TEXT)
       	SQL
       	DB[:conn].execute(sql)
		end

		def self.drop_table
       sql = <<-SQL
       	DROP TABLE dogs 
       	SQL
       	DB[:conn].execute(sql)

		end
           

		     def save
           sql =  <<-SQL 
   		     INSERT INTO dogs (name, breed) VALUES (? , ?)
      		SQL
      		DB[:conn].execute(sql, self.name, self.breed)
            #@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
             #binding.pry
             self
           
         end


         def self.create(name:, breed:)
              dog = Dog.new(:name => name , :breed => breed)
               #binding.pry
               dog.save
               dog
          end

           def self.find_by_id(dog)
             #binding.pry
              sql = <<-SQL 
              SELECT * FROM dogs where id = ? 
               SQL
              dogs =  DB[:conn].execute(sql, dog)[0]
              
              Dog.new(:id => dogs[0], :name => dogs[1], :breed => dogs[2])
             #binding.pry
           end
            def self.new_from_db(dog)
                #binding.pry
                new_dog = Dog.new(:id => dog[0], :name => dog[1], :breed => dog[2])
                binding.pry
              
             end

             def self.find_by_name(dog)
                sql = <<-SQL 
              SELECT * FROM dogs where name = ? 
               SQL
              dogs =  DB[:conn].execute(sql, dog).flatten
             Dog.new(:id => dogs[0], :name => dogs[1], :breed => dogs[2])
             end


            def update
           
               sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
               # binding.pry
                DB[:conn].execute(sql)
           end
          
          
          def self.find_or_create_by(name:, breed:)
            sql = <<-SQL 
              SELECT * FROM dogs where name = ? AND breed =? LIMIT 1
               SQL
              #binding.pry
              dogs =  DB[:conn].execute(sql, name, breed)
            #binding.pry
              if dogs.empty?

                n_dog = self.create(:name => name, :breed => breed)

              else
                n_dog = self.new_from_db(dogs[0])
              end
              n_dog
         
               end
       


        



end