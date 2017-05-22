class PlayController < ApplicationController
  def game
    @grid = generate_grid
  end

  def score
    @word_submitted = params[:word]
    @grid = params[:grid]
    @start_time = params[:start_time]
    @end_time = end_time
    @result = run_game(@word_submitted, @grid, @start_time, @end_time)
  end

  private

#GAME
  def generate_grid
    grid = Array.new(9) { ('A'..'Z').to_a[rand(26)] }
  end


#SCORE
  def end_time
    Time.now.to_i
  end


  def run_game(attempt, grid, start_time, end_time)
    time = end_time.to_i - start_time.to_i
    result = { time: time }

    result[:translation] = get_translation(attempt)
    result[:score], result[:message] = score_and_message(
      attempt, result[:translation], grid, result[:time])

    result
  end

  def get_translation(word)
    api_key = "YOUR_SYSTRAN_API_KEY"
    begin
      response = open("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{api_key}&input=#{word}")
      json = JSON.parse(response.read.to_s)
      if json['outputs'] && json['outputs'][0] && json['outputs'][0]['output'] && json['outputs'][0]['output'] != word
        return json['outputs'][0]['output']
      end
    rescue
      if File.read('/usr/share/dict/words').upcase.split("\n").include? word.upcase
        return word
      else
        return nil
      end
    end
  end

  def score_and_message(attempt, translation, grid, time)
    if included?(attempt.upcase, grid)
      if translation
        score = compute_score(attempt, time)
        [score, "Well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end

  def included?(guess, grid)
    guess.split.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end
end
