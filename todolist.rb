# ToDoList Command Line Ruby with MySQL

# Before running this code, make sure to have a todolist mysql table with author, title, task and times columns 
# or better still, create yours and adjust code as you wish

# Importing the needed libraries
require 'mysql2'   # needed for database
require 'optparse' # needed for command line argument parsing
require 'ostruct'  # same as above
require 'colorize' # beautifying outputs

# Command-Line Argument parser
options = OpenStruct.new
option_parser = OptionParser.new do |opt|
  opt.on('-h', '--host Host IP', 'Host Server IP') { |o| options.host = o }
  opt.on('-u', '--user Username', 'UserName') { |o| options.username = o }
  opt.on('-p', '--password Password', 'Password') { |o| options.password = o }
  opt.on('-d', '--dbname = brofosem', 'Dbname') { |o| options.dbname = o }
end.parse!

begin
    option_parser.parse!
  rescue OptionParser::MissingArgument, OptionParser::InvalidOption
    puts "Error: Invalid or missing option."
    puts option_parser
    exit 1
end

# if s,u,p,d flags are not activated, do the following
missing_flags = []
missing_flags << "s" unless options.host
missing_flags << "u" unless options.username
missing_flags << "p" unless options.password
missing_flags << "d" unless options.dbname

unless missing_flags.empty?
puts "Error: The following flags are not activated: #{missing_flags.join(', ')}"
puts option_parser
exit 1
end


# Initialize connection to MySQL
client = Mysql2::Client.new(:host => options.host , :username => options.username , :password => options.password, :database => options.dbname)

# Request and Accept User Input
puts "Would you like to read(R), delete(D), update(U) a new task"
choice = gets 

# Number of Rows
num_task = client.query("SELECT count(*) FROM todolist;")

if choice.chomp == 'U' || choice.chomp == 'update' || choice.chomp == 'u'
  # Update section
  puts "Creating Task..."
  puts "This is task number #{num_task.first["COUNT(*)"].to_i + 1}"
  print "Author:".red
  author = gets
  print "Title: ".yellow
  title = gets
  print "Task: ".green
  task = gets
  time_now = Time.now.strftime("%H:%M:%S")
  puts '=================================================================='
  # Apparently, it is very important to use prepare statement before executing, note to self, use this procedure in the future 
  # 'cause you lost valuable time on it
  pst = client.prepare "INSERT INTO todolist(author,title,task,times) VALUES (?,?,?,?)"
  pst.execute author.chomp,title.chomp,task.chomp,time_now
  puts "Task added successfully..."

elsif choice.chomp == 'R' || choice.chomp == 'read' || choice.chomp == 'r'
  # Reading / Displaying database table section
  puts '=================================================================='
  result = client.query("SELECT * FROM todolist;")
  result.each do |row| puts row end 
  puts '=================================================================='

elsif choice.chomp == 'D' || choice.chomp == 'delete' || choice.chomp == 'd'
  # Deleting Section
  print "Title to be deleted: ".yellow
  title = gets
  # Deleting with respect to title, since titles should be unique
  pst = client.prepare "DELETE FROM todolist WHERE title=?"
  pst.execute title.chomp 
  puts "Task deleted successfully..."

else puts "Wrong choice" # if choice.chomp != 'r','read,'R', or , 'D','delete','d', or 'u','update,'U' do this
end

# Close connection to MySQL
client.close
    



