��� �� <u�� <0r<9w,02�����������p ���L�!���c � ���G�G�G�G�G�G��I �ݺ��: �@�2�t������* � � ����n�" ���� � � ����l�	 ��P�	�!X�Q� ��Y�1Zj�$$$$$$ 	
Misc Tests v 0.1
$Usage: misctest <option> where <option> is 0 through 9
       misctest 0 - Do 6 rapid 0x320 writes forever
       misctest 1 - Do 6 rapid 0x320 reads forever
       misctest 2 - Do 16 rapid 0x320 repnz writes forever
       misctest 3 - Do 16 rapid 0x320 repnz reads forever
$Note: This operation will run forever (locks system)
$