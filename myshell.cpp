#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/wait.h>
#include <string>
#include <iostream>
#include <fstream>
using namespace std;

/**------------------------------------------------------------------------------------------------------------------
PROJEKT 2 @martapolcyn #322942

Uzupełnić program interpretera poleceń msh (plik msh.c dostępny na stronie przedmiotu w zakładce Przykłady i opisany
w wykładzie 8) w następujący sposób:
	1.	Dodać polecenia wbudowane:
		a.  waitall - czekaj na zakończenie wszystkich procesów drugoplanowych i podaj przyczynę zakończenia
			(exit czy sygnał) oraz kod wyjścia na stdout.
		b.	repeat N program arg … - uruchom podany program  N razy.
	2.	Zmodyfikować polecenie wbudowane exit - przed zakończeniem działania interpreter sprawdza, czy nie ma procesów
		potomnych w stanie zombie (wykorzystać waitpid() z flagą WNOHANG), wypisuje identyfikatory PID i kody wyjścia
		zakończonych procesów.
--------------------------------------------------------------------------------------------------------------------*/

// vector<pid_t> pids;

int AnalizujPolecenie(char *bufor, char *arg[])
{
	int counter = 0;
	int i = 0, j = 0;

	while (bufor[counter] != '\n')
	{
		while (bufor[counter] == ' ' || bufor[counter] == '\t')
			counter++;
		if (bufor[counter] != '\n')
		{
			arg[i++] = &bufor[counter];
			while (bufor[counter] != ' ' && bufor[counter] != '\t' && bufor[counter] != '\n')
				counter++;
			if (bufor[counter] != '\n')
				bufor[counter++] = '\0';
		}
	}
	bufor[counter] = '\0';
	arg[i] = NULL;
	if (i > 0)
		while (arg[i - 1][j] != '\0')
		{
			if (arg[i - 1][j] == '&')
			{
				if (j == 0)
					arg[i - 1] = NULL;
				else
					arg[i - 1][j] = '\0';
				return 1;
			}
			j++;
		}
	return 0;
}

int Wykonaj(char **arg, int bg)
{
	pid_t pid;
	int status;

	if ((pid = fork()) == 0)
	{
		execvp(arg[0], arg);
		perror("Blad exec");
		exit(1);
	}
	else if (pid > 0)
	{
		// add every pid of a newly created process to pids vector
		// pids.push_back(pid);
		if (bg == 0)
			waitpid(pid, &status, 0);
		return 0;
	}
	else
	{
		perror("Blad fork");
		exit(2);
	}
}

int ZmodyfikowanyExit()
{
	pid_t cpid;
	int wstatus;

	while ((cpid = waitpid(-1, &wstatus, WNOHANG)) > 0)
	{
		if (WIFEXITED(wstatus))
		{
			printf("Process %d exited, status=%d\n", cpid, WEXITSTATUS(wstatus));
		}
		else if (WIFSIGNALED(wstatus))
		{
			printf("Process %d killed by signal %d\n", cpid, WTERMSIG(wstatus));
		}
		else if (WIFSTOPPED(wstatus))
		{
			printf("Process %d stopped by signal %d\n", cpid, WSTOPSIG(wstatus));
		}
		else if (WIFCONTINUED(wstatus))
		{
			printf("Process %d continued\n", cpid);
		}
	}

	return 0;
}

int WaitAll()
{
	int wstatus;
	while (1)
	{
		int cpid = waitpid(-1, &wstatus, 0);

		if (cpid == -1)
		{
			break;
		}

		if (WIFEXITED(wstatus))
		{
			printf("Process %d exited, status=%d\n", cpid, WEXITSTATUS(wstatus));
		}
		else if (WIFSIGNALED(wstatus))
		{
			printf("Process %d killed by signal %d\n", cpid, WTERMSIG(wstatus));
		}
	}
	return 0;
}

int Repeat(int N, char **arg, int bg)
{
	for (int i = 0; i < N; ++i)
	{
		Wykonaj(arg, bg);
	}

	return 0;
}

int main()
{
	char bufor[80];
	char *arg[10];
	int bg;

	while (1)
	{
		printf("msh $ ");
		fgets(bufor, 80, stdin);
		bg = AnalizujPolecenie(bufor, arg); // tworzy tablice arg[]

		if (arg[0] == NULL)
		{
			continue;
		}
		else if (strcmp(arg[0], "exit") == 0)
		{
			ZmodyfikowanyExit();
			exit(0);
		}
		else if (strcmp(arg[0], "waitall") == 0)
		{
			WaitAll();
		}
		else if (strcmp(arg[0], "repeat") == 0)
		{
			int N = atoi(arg[1]);
			char *arr[8];
			for (int i = 0; i < 8; i++)
			{
				arr[i] = arg[i + 2];
			}
			Repeat(N, arr, bg);
		}
		else
		{
			Wykonaj(arg, bg);
		}
	}
}