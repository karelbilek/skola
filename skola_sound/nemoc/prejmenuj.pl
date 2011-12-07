for  $f (<*.aiff>) {
    $s = $f;
    $s =~ s/aiff/wav/;
    system("sox $f $s");
}
