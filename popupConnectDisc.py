#name:		popupConnectDisc.py
#description:	Script that shows a pyqt (Qt) popup to ask the user to connect the harddrive
#date:		21 oct 2021
#author:	rubecons

import sys
import os.path
from PyQt5.QtWidgets import QApplication, QDialog, QLabel, QVBoxLayout, QPushButton
from PyQt5.QtCore import QTimer

win = None
executionNotNow = 0
class WindowAsksDriveConnection(QDialog):
    def __init__(self):
        global timer

        super().__init__()
        self.setWindowTitle("laptop backup")
        message = QLabel("\nIt is necessary to connect the hard drive to perform the backup\n")
        button = QPushButton("Not Now")
        vBox = QVBoxLayout()
        vBox.addWidget(message)
        vBox.addWidget(button)
        self.setLayout(vBox)
        timer = QTimer(self)
        timer.start(3000)
        timer.timeout.connect(self.testIfArgDirExists)
        button.clicked.connect(self.notNow)

    def testIfArgDirExists(self):
        global executionNotNow
        #print ("testIfArgDirExists")
        if (os.path.isdir(sys.argv[1])):
            print("Directory detected")
            executionNotNow = 0
            timer.stop()
            self.close()
	
    def notNow(self):
        global executionNotNow
		#line below means there is a NotNow, If it was Now, it would have let the variable executionNotNow to 0
        executionNotNow = 1
        timer.stop()
        print("NotNow")
        self.close()


if __name__ == '__main__':
    print("popupConnectDisc")
    print('fileToDetect {}'.format(sys.argv[1]))
    app = QApplication(sys.argv)
    win = WindowAsksDriveConnection()
    #win.exec()
    win.show()
    app.exec_()
    
    print('executionNotNow = {}'.format(executionNotNow))
    sys.exit(executionNotNow)
