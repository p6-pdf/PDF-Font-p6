use v6;
use PDF::Font::Loader;
use PDF::Lite;
use PDF::Content::FontObj;
use Test;
my PDF::Lite $pdf .= new;
my $page = $pdf.add-page;
my PDF::Content::FontObj $times = PDF::Font::Loader.load-font: :file<t/fonts/TimesNewRomPS.pfb>;
# deliberate mismatch of encoding scheme and glyphs. PDF::Content
# should build an encoding based on the differences.
my $zapf = PDF::Font::Loader.load-font: :file<t/fonts/ZapfDingbats.pfa>, :!embed;

$page.text: {
   .font = $times;
   .text-position = [10, 700];
   .say: 'Hello, world';
   .font = $zapf;
   .say: "★☎☛☞♠♣♥";
   for $times, $zapf -> $font {
       my $s;
       my $n = 0;
       .font = $font;
       $font.face.forall-chars: :!load, -> $_ {
           $s ~= .char-code.chr;
           $s ~= ' ' if $n++ %% 10
        };
       .say: $s, :width(400);
       .say: '';
   }
}

# ensure consistant document ID generation
srand(123456);
lives-ok { $pdf.save-as: "t/type1.pdf"; };

done-testing;

