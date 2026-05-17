function envsource
    for line in (cat $argv[1] | grep -v '^#' | grep -v '^$')
        set item (string split -m 1 '=' $line)
        set -gx $item[1] $item[2]
    end
end
