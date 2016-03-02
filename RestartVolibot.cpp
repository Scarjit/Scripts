// RestartVolibot.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <cstdio>
#include <windows.h>
#include <iostream>
#include <string>
#include <thread>
#include <chrono>
#include <sstream>

using namespace std;

int main()
{
	ostringstream os;
	os << "Stop-Process -processname Voli*";
	string op = "open";
	string pspath = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\PowerShell.exe";
	string param = os.str();

	ostringstream os2;
	os2 << "Get-ChildItem Voli* | Foreach-Object{Start-Process $_}";
	string param2 = os2.str();


	while (true)
	{
		cout << "Killing VoliBot..." << endl;
		ShellExecuteA(NULL, op.c_str(), pspath.c_str(), param.c_str(), NULL, SW_HIDE);
		this_thread::sleep_for(chrono::seconds(5));

		cout << "Killing League of Legends..." << endl;
		system("taskkill /F /IM LolClient.exe");
		system("taskkill /F /IM \"League of Legends.exe\"");
		this_thread::sleep_for(chrono::seconds(1));

		cout << "Starting Volibot" << endl;
		ShellExecuteA(NULL, op.c_str(), pspath.c_str(), param2.c_str(), NULL, SW_HIDE);

		cout << "Sleeping 30 Minutes" << endl;
		this_thread::sleep_for(chrono::minutes(30));
	}
	return 0;
}

