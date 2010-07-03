--- /usr/local/share/lib/latex2html//versions/math.pl.old	Sat Oct  9 16:36:53 2004
+++ /usr/local/share/lib/latex2html/versions/math.pl	Sat Oct  9 16:37:00 2004
@@ -1412,6 +1412,7 @@
 	    while ($pre_test =~ s/(($O|$OP)\d+($C|$CP))(.*)\1/$4/) {};
 	    $use_all = 1 if ($pre_test=~s/($O|$OP)\d+($C|$CP)//);
 	    if (!$use_all) {
+		$pre_test = $pre_text;
 	        while ($pre_test =~ s/\\begin(($O|$OP)\d+($C|$CP))(.*)\\end\1/$4/){};
 		$use_all = 1 if ($pre_test=~s/\\(begin|end)($O|$OP)\d+($C|$CP)//);
 	    };
