// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function() 
    { 
        $("#stats").tablesorter({widgets: ['zebra']});; 
    } 
); 

$(document).ready(function() 
    { 
        $("#history").tablesorter({widgets: ['zebra']});; 
    } 
);

$(document).ready(function() 
    { 
        $("#league_avg").tablesorter({widgets: ['zebra']});; 
    } 
);

$(document).ready(function() 
    { 
        $("#winner_avg").tablesorter({widgets: ['zebra']});; 
    } 
);
$(document).ready(function() 
    { 
        $("#strength").tablesorter({widgets: ['zebra']});; 
    } 
);