class RecordsController < ApplicationController
  caches_page :head_to_head
  
  def head_to_head
    @margin_victory = Detail.all(:select => "name, opponent, year, week, points,
                                                opponent_points, ABS(points-opponent_points) as difference",
                                    :order => "year, difference")

    @margins = Detail.all(:select => "year, MAX(ABS(points-opponent_points)) as max_margin, MIN(ABS(points-opponent_points)) as min_margin", :group => "year", :order => "year")
    @max_margin = Detail.all(:select => "*, ABS(points-opponent_points) as difference", :order => "year",
                            :conditions => "points-opponent_points IN (#{@margins.collect(&:max_margin).join(", ")})")
    @min_margin = Detail.all(:select => "*, ABS(points-opponent_points) as difference", :order => "year",
                            :conditions => "points-opponent_points IN (#{@margins.collect(&:min_margin).join(", ")})")    
        
    @strengths = Detail.all(:select => "name, opponent, year, week, avg(points) as avg_points, 
                                                avg(opponent_points) as avg_opponent_points",
                                    :group => "name, year", :order => "year, avg_opponent_points")
                                    
    @all_strengths = Detail.all(:select => "name, opponent, year, week, avg(points) as avg_points, 
                                            avg(opponent_points) as avg_opponent_points",
                                :conditions => "year >= '2007'",
                                :group => "name", :order => "avg_opponent_points")
    @strength_years = @strengths.collect(&:year).uniq
    @max_strength = []
    @min_strength = []
    @strength_years.each do |year|
      @max_strength << @strengths.collect{|u|u.avg_opponent_points if u.year == year}.compact.max
      @min_strength << @strengths.collect{|u|u.avg_opponent_points if u.year == year}.compact.min
    end     
    
    @ranks = Summary.all(:select => "name, year, rank, reg_season_rank")
    
    @strength_chart = HighChart.new('graph') do |f|
      f.options[:title][:text] = "Strength of Schedule since 2007"
      f.options[:chart][:defaultSeriesType] = "column"
      f.options[:legend][:layout] = "horizontal"
      f.options[:x_axis][:categories] = @all_strengths.collect(&:name).uniq  
      f.options[:x_axis][:labels][:rotation] = -45
      f.options[:y_axis][:title][:text] = "Avg Opponent Points"

      f.series("Avg Opponent Points", @all_strengths.collect{|u|u.avg_opponent_points.to_f})
    end
  end
  
  
  def historical
    @names = Summary.all(:conditions => "year = '2009'").collect(&:name).uniq
    
    if params[:name] && params[:name] != "All"
      @summaries = Summary.all(:conditions => "year > 2003 AND name = '#{params[:name]}'")      
      @league_avg = Summary.all(:group => "year", :conditions => "year > 2003", 
                               :select => "year, avg(win_percentage) as win_percent, avg(points) as points")
                               
      @points_chart = HighChart.new('graph') do |f|
       f.options[:title][:text] = "Points Comparison"
       f.options[:chart][:defaultSeriesType] = "line"
       f.options[:legend][:layout] = "horizontal"
       f.options[:x_axis][:categories] = @summaries.collect(&:year).uniq
       f.options[:y_axis][:title][:text] = "Points"

       f.series(params[:name], @summaries.collect{|u|u.points.to_f if u.name == params[:name]}.compact)
       f.series('League Average', @league_avg.collect{|u|u.points.to_f if @summaries.collect(&:year).uniq.include?(u.year)}.compact)
      end
      
    else
      @summaries = Summary.all
    end    
  end
  
  def team_statistics
    @all_time = Summary.all(:select => "avg(rank) as rank, avg(reg_season_rank) as reg_rank, name, sum(wins) as wins,
                                        sum(losses) as losses, (sum(wins))/(sum(wins)+sum(losses))*100 as win_percent,
                                        sum(points) as points, sum(points)/count(champion) as points_per_year, count(champion) as years_played,
                                        sum(champion) as championships, avg(draft_position) as draft_position",
                             :group => "name", :order => "rank, reg_rank", :conditions => "year > 2003")
                             
    @winner_avg = Summary.all(:joins => "LEFT JOIN summaries s2 ON summaries.year = s2.year", :conditions => "summaries.champion = 1 AND summaries.year > '2003'",
                              :group => "s2.year", :select => "summaries.year as year, summaries.reg_season_rank as rank,
                                                              (sum(summaries.wins))/(sum(summaries.wins)+sum(summaries.losses))*100 as win_percent,
                                                              summaries.draft_position as draft, summaries.points, avg(s2.points) as league_points")
                                                                                                                         
    @names = Summary.all(:conditions => "year = '2009'").collect(&:name).uniq
    
    if params[:name] && params[:name] != "All"
      @summaries = Summary.all(:conditions => "year > 2003 AND name = '#{params[:name]}'")      
      @league_avg = Summary.all(:group => "year", :conditions => "year > 2003", 
                               :select => "year, avg(win_percentage) as win_percent, avg(points) as points")
      
      @points_chart = HighChart.new('graph') do |f|
        f.options[:title][:text] = "Points Comparison"
        f.options[:chart][:defaultSeriesType] = "line"
        f.options[:legend][:layout] = "horizontal"
        f.options[:x_axis][:categories] = @summaries.collect(&:year).uniq
        f.options[:y_axis][:title][:text] = "Points"

        f.series(params[:name], @summaries.collect{|u|u.points.to_f if u.name == params[:name]}.compact)
        f.series('League Average', @league_avg.collect{|u|u.points.to_f if @summaries.collect(&:year).uniq.include?(u.year)}.compact)
      end
    else
      @summaries = Summary.all
    end    
  end
end
