# shoes_translator.rb
require 'open-uri'

PATH = "http://ajax.googleapis.com/ajax/services/language/" \
       "translate?v=1.0&langpair=en%7C"
Q = "&q="

AW, AH = 200, 30
ERR = "Error: NULL pointer given.\n" \
      "Can't reset clipboard so far.\n" \
      "Copy first and restart."
      
class Translator < Shoes
  url '/', :index
  url '/translate', :translate
  
  def index
    background lightblue..limegreen, :angle => 90
    para strong "Select a language (click)\n\n"
    IO.readlines('../data/languages.txt').each do |line|
      country, lang = line.split ','
      b = nil
      f = flow do
        b = background(gold, :curve => 5).hide
        para country
      end
      f.style :width => 95
      f.hover{b.show}
      f.leave{b.hide}
      f.click{$country, $lang = country, lang.strip; visit '/translate'}
    end
  end
  
  def translate
    background white
    make_words_with_flow
    make_dic_area
  end
  
  def make_words_with_flow 
    style(Link, :stroke => crimson, :underline => nil)
    style(LinkHover, :stroke => tomato, :fill => nil, :underline => nil) 
    para link(strong('paste'), :click => '/translate'), :left => 10
    para link(strong($country), :click => '/'), :left => 80
    motion{line 5, 25, width - 8, 25, :stroke => green }
    
    text = clipboard rescue (alert(ERR); exit)
    words = text.split(' ')
    flows = []
  
    flow do
      words.each do |w|
        w += ' '
        flows << flow{para code(w)}
        flows[-1].style :width => w.length * 10
      end
    end
  
    flows.each_with_index do |f, n|
      blk = proc do
        #debug  "#{words[n]} : #{f.left},#{f.top}"
        mess = words[n].downcase.delete 'a-z'
        word = words[n].delete mess
        @msg.text =  search word
        w = @msg.text.length * 7
        f.left + w < width ?  x = f.left : x = f.left - w
        @area.move x, f.top + 60
        @area.style :width => w
        @area.show
      end
      f.hover &blk
      f.click &blk
      f.leave{@area.hide}
    end
  end
  
  def make_dic_area
    @area = stack :width => AW, :height => AH do
      background lightblue, :curve => 5
      @msg = para '', :font => "MS UI Gothic", :size => "xx-small"
    end.hide
  end
  
  def search word
    word = 'unknown' if word.empty?
    result = open(PATH + $lang + Q + word).read.split('"')[5]
    result =  search word[0...-1] if result.empty?
    return word + ': ' + result
  end
end

Shoes.app :title => 'Shoes Translator 0.0.6', :width => 400, :height => 400