class HomeController < ApplicationController
  caches_page :index
  
  def index
    @league_avg = Summary.all(:joins => "LEFT JOIN summaries s2 ON summaries.year = s2.year", :conditions => "summaries.champion = 1 AND summaries.year > '2003'",
                              :group => "s2.year", :select => "summaries.name as name, summaries.year as year, summaries.reg_season_rank as rank, 
                                                              summaries.draft_position as draft, summaries.points, avg(s2.points) as league_points")  
    
    @champion_chart = HighChart.new('graph') do |f|
      f.options[:title][:text] = "Champion Comparison"
      f.options[:chart][:defaultSeriesType] = "bar"
      f.options[:chart][:inverted] = true
      f.options[:legend][:layout] = "horizontal"
      f.options[:x_axis][:categories] = @league_avg.collect{|u|[u.year.to_s.gsub("20", "'"), u.name].join(" ")}
      f.options[:y_axis][:title][:text] = "Points"
      f.options[:x_axis][:labels][:rotation] = 0
      
      f.series('Winner Points', @league_avg.collect{|u|u.points.to_f})
      f.series('Average League Points', @league_avg.collect{|u|u.league_points.to_f})
    end
  end
end
