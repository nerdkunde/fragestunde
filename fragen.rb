#!/usr/bin/env ruby

require 'bundler/setup'
require 'octokit'
require 'chromatic'

class NerdkundeFrageStunde
  def initialize
    puts "Lade GitHub issues von nerdkunde/fragestunde"
    @handled_issues = []
    @issues = Octokit.issues("nerdkunde/fragestunde", limit: 1000)
  end

  def start_game
    # Clear Screen
    puts "\e[H\e[2J"

    puts "Willkommen zur Nerdkunde Fragestunde".yellow
    puts "n - Nächste Frage, q - Beenden, r - Fragen neu laden"

    begin
      system("stty raw -echo")
      while true
        str = STDIN.getc
        case str
        when 'n'
          pick_question
        when 'r'
          @issues = Octokit.issues("nerdkunde/fragestunde")
          puts "Issues geladen ... es kann weitergehen\r"
        when 'q'
          puts "Ende\r"
          break
        end
      end
    ensure
      system("stty -raw echo")
    end
  end


  def pick_question
    if @handled_issues.count < @issues.count
      begin
        current_issue = if @handled_issues.count == 0
                          @issues.select { |issue| issue.number == 32 }.first
                        else
                          @issues.sample
                        end
      end while @handled_issues.include?(current_issue.number)

      labels = current_issue.labels.map { |label| " #{label.name} ".blue.on_white }
      @handled_issues << current_issue.number

      puts "\n\n\n#{labels.join} #{current_issue.title.yellow}\r"
      puts
    else
      puts "#{"Keine weiteren Fragen".red}\r"
    end
  end
end

NerdkundeFrageStunde.new.start_game
