class Dog

attr_accessor :name, :breed, :id 

# def db 
#   @db = DB[:conn]
# end 

  def initialize(name:, breed: , id: nil)
      @name = name
      @breed = breed
      @id = id 
  end 

  def self.create_table
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
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  end 
  self 
  end 


  def self.create(name:, breed:)
    thing = Dog.new(name: name, breed: breed)
    thing.save
    thing
  end

    def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE id = '#{id}'
    LIMIT 1
    SQL
    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end.first
  end 
      def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = '#{name}'
    LIMIT 1
    SQL
    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end.first
  end 


  def self.new_from_db(row)
    dog = self.new(name: row[1], breed: row[2])
    dog.id = row[0]
    dog
    # create a new Student object given a row from the database
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs where name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_new = dog[0]
      dog = Dog.new(id: dog_new[0], name: dog_new[1], breed: dog_new[2])
    else
      dog = self.create(name: name, breed: breed)
    end  
    dog
   end  

   def update
      DB[:conn].execute("UPDATE dogs SET name = '#{self.name}', breed = '#{self.breed}' WHERE id = '#{self.id}'") 
    end


end 