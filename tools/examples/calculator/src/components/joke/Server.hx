package components.joke;

import php.Lib;
import haquery.server.HaqComponent;

class Server extends HaqComponent
{
    static private var jokes = [ 
        "Two plus two equals five. If you want.",
        "I'll be calc.",
        "The price is good, the calculator is death!",
        "The village of battery? So take that!",
        "Need to calculate the square of the circle? This is not a problem.",
        "Now banana.",
        "Year 2300. I think - I think, therefore I exist."
     ];

    public function preRender()
    {
        var days = Math.floor(Date.now().getTime() / (60*60*24*1000));
		q('#text').html(jokes[days % jokes.length]);
    }
}
