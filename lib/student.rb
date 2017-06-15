require_relative "../config/environment.rb"
require 'pry'

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :name, :grade, :id
  # attr_reader :id

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students;"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      sql = "SELECT * FROM students ORDER BY id DESC LIMIT 1";
      row = DB[:conn].execute(sql).flatten
      @id = row[0]
    end
  end

  def update
    updating_sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
    SQL
    updated_row = DB[:conn].execute(updating_sql, self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save
  end

  def self.new_from_db(row)
    student = self.new(row[1], row[2])
    student.id = row[0]
    student
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name).flatten
    self.new_from_db(row)
  end

end
