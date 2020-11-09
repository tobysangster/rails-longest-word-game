require 'open-uri'
require 'json'
class GamesController < ApplicationController

    def new
        @grid = generate_grid(10)
        @start_time = Time.now
    end

    def score
        grid = params[:grid].split("")
        @attempt = params[:attempt]
        start_time = Time.parse(params[:start_time])
        end_time = Time.now
        @result = run_game(@attempt, grid, start_time, end_time)
    end
       
    def compute_score(attempt, time_taken)
        (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
    end
    
    def run_game(attempt, grid, start_time, end_time)
        result = { time: end_time - start_time }
        result[:score], result[:message] = score_and_message(
            attempt, grid, result[:time])
            result
    end

    def generate_grid(gridlength)
        Array.new(gridlength) { ('A'..'Z').to_a[rand(26)] }
    end

    def english_word?(word)
        response = open("https://wagon-dictionary.herokuapp.com/#{word}")
        json = JSON.parse(response.read)
        return json['found']
    end
    
    def included?(guess, grid)
        guess.split("").all? { |letter| grid.include? letter }
    end

    def score_and_message(attempt, grid, time)
        if english_word?(attempt)
          if included?(attempt.upcase, grid)
            score = compute_score(attempt, time)
            [score, "Well done, you got it!"]
          else
            [0, "That's not in the grid"]
          end
        else
          [0, "That's not a word!"]
        end
    end
end

