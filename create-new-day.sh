if [ -z $1 ]; then
    echo "You need to specify a day"
    exit 1
fi
day=$1;

sourceFile=Sources/AOC2023Core/Days/Day$day.swift
inputFile=Sources/AOC2023Core/Inputs/input_${day}_1.txt
echo generating $sourceFile

if test -f $sourceFile; then
    echo "Day already exists"
    exit 2
fi

touch $inputFile

cp TemplateDay.swift Day$day.swift

sed -i '' "1,13s/[0-9]/$day/" Day$day.swift

mv Day$day.swift $sourceFile

touch tempfile.tmp

awk -v day=$day 'NR==30{print "\t\tcase " day ": return try Day"day"(testInput: testInput)"}1' Sources/AOC2023Core/AOC2023.swift > tempfile.tmp

mv tempfile.tmp Sources/AOC2023Core/AOC2023.swift