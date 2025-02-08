# Set up the constants:
$ObjectPronouns = 'Her', 'Him', 'Them'
$PossesivePronouns = 'Her', 'His', 'Their'
$PersonalPronouns = 'She', 'He', 'They'
$States = 'California', 'Texas', 'Florida', 'New York', 'Pennsylvania', 'Illinois', 'Ohio', 'Georgia', 'North Carolina', 'Michigan'
$Nouns = 'Athlete', 'Clown', 'Shovel', 'Paleo Diet', 'Doctor', 'Parent', 'Cat', 'Dog', 'Chicken', 'Robot', 'Video Game', 'Avocado', 'Plastic Straw', 'Serial Killer', 'Telephone Psychic'
$Places = 'House', 'Attic', 'Bank Deposit Box', 'School', 'Basement', 'Workplace', 'Donut Shop', 'Apocalypse Bunker'
$When = 'Soon', 'This Year', 'Later Today', 'RIGHT NOW', 'Next Week'

function generateAreMillennialsKillingHeadline { 
    $noun = $Nouns | Get-Random
    'Are Millennials Killing the {0} Industry?' -f $noun
}

function generateWhatYouDontKnowHeadline { 
    $noun = $Nouns | Get-Random
    $pluralNoun = ($Nouns | Get-Random) + 's'
    $when = $WHEN | Get-Random

    'Without This {0}, {1} Could Kill You {2}' -f $noun, $pluralNoun, $when
}

function generateBigCompaniesHateHerHeadline {
    $pronoun = $ObjectPronouns | Get-Random
    $state = $States | Get-Random
    $noun1 = $Nouns | Get-Random
    $noun2 = $Nouns | Get-Random
    
    'Big Companies Hate {0}! See How This {1} {2} Invented a Cheaper {3}' -f $pronoun, $state, $noun1, $noun2
}
 
function generateYouWontBelieveHeadline {
    $state = $States | Get-Random
    $noun = $Nouns | Get-Random
    $pronoun = $PossesivePronouns | Get-Random
    $place = $Places | Get-Random
    
    "You Won't Believe What This {0} {1} Found in {2} {3}" -f $state, $noun, $pronoun, $place
}
function generateDontWantYouToKnowHeadline {
    $pluralNoun1 = ($Nouns | Get-Random) + 's'
    $pluralNoun2 = ($Nouns | Get-Random) + 's'

    "What {0} Don't Want You To Know About {1}" -f $pluralNoun1, $pluralNoun2
}

function generateGiftIdeaHeadline {    
    $number = Get-Random -Min 7 -Max 16
    $noun = $Nouns | Get-Random
    $state = $States | Get-Random

    '{0} Gift Ideas to Give Your {1} From {2}' -f $number, $noun, $state
}
function generateReasonsWhyHeadline {
    $number1 = Get-Random -Min 3 -Max 20
    $pluralNoun = ($Nouns | Get-Random) + 's'
    $number2 = Get-Random -Min 3 -Max ($number1 + 1)

    '{0} Reasons Why {1} Are More Interesting Than You Think (Number {2} Will Surprise You!)' -f $number1, $pluralNoun, $number2
}

function generateJobAutomatedHeadline {
    $state = $States | Get-Random
    $noun = $Nouns | Get-Random
    
    $i = Get-Random -Min 0 -Max 3
    
    $pronoun1 = $PossesivePronouns[$i]
    $pronoun2 = $PersonalPronouns[$i]

    if ($pronoun1 -eq 'their') {
        "This {0} {1} Didn't Think Robots Would Take {2 } Job. {3} Were Wrong." -f $state, $noun, $pronoun1, $pronoun2
    }
    else {
        "This {0} {1} Didn't Think Robots Would Take {2} Job. {3} Was Wrong." -f $state, $noun, $pronoun1, $pronoun2
    }
}

'Clickbait Headline Generator'
''
'Our website needs to trick people into looking at ads!'
''

$numberOfHeadlines = 0
while ($true) {
    $response = Read-Host 'Enter the number of clickbait headlines to generate'

    if ($response -notmatch "^\d+$") {
        'Please enter a number.'
    }
    else {
        $numberOfHeadlines = $response        
        break
    }
}

''
1..$numberOfHeadlines | ForEach-Object {
    $clickbaitType = Get-Random -Minimum 1 -Maximum 9
    switch ($clickbaitType) {
        1 { $headLine = generateAreMillennialsKillingHeadline }
        2 { $headLine = generateWhatYouDontKnowHeadline }
        3 { $headLine = generateBigCompaniesHateHerHeadline }
        4 { $headLine = generateYouWontBelieveHeadline }
        5 { $headLine = generateDontWantYouToKnowHeadline }
        6 { $headLine = generateGiftIdeaHeadline }
        7 { $headLine = generateReasonsWhyHeadline }
        8 { $headLine = generateJobAutomatedHeadline }
    }
    $headLine
}

''
$website = 'wobsite', 'blag', 'Facebuuk', 'Googles', 'Facesbook', 'Tweedie', 'Pastagram' | Get-Random
$when = ($When | Get-Random).tolower()

"Post these to our $website $when!"