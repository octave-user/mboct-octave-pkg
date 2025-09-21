// Copyright (C) 2018(-2020) Reinhard <octave-user@a1.net>

// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program; If not, see <http://www.gnu.org/licenses/>.

#include "config.h"
#include <octave/oct.h>

#if defined(HAVE_WIN32)
#include <sstream>
#include <vector>
#include <windows.h>
#else
#include <octave/interpreter.h>
#endif

// PKG_ADD: autoload ("shell", "__mboct_octave_proc__.oct");
// PKG_DEL: autoload ("shell", "__mboct_octave_proc__.oct", "remove");

DEFUN_DLD(shell, args, nargout,
          "-*- texinfo -*-\n"
          "@deftypefn {} [@var{status}, @var{output}] = shell(@var{command}, @var{return_output}, @var{type})\n\n"
          "Execute a command within the POSIX shell on WIN32 systems with Msys.\n"
          "On Unix like systems, shell is equivalent to Octave's builtin system function.\n\n"
          "@var{command} @dots{} command line to be passed to sh after -c\n\n"
          "@var{return_output} @dots{} return the output of the command as a string\n\n"
          "@var{type} @dots{} one of \"async\",  \"sync\"\n\n"
          "@example\n"
          "[status, output] = shell(\"ls -lhF .\", true, \"sync\");\n\n"
          "@end example\n"
          "@end deftypefn\n")
{
#if defined(HAVE_WIN32)
     octave_value_list retval;
     std::string command, type;
     bool return_output = false;
     bool async = false;

     if (args.length() < 1 || args.length() > 3 || nargout > 2) {
          print_usage();
          return retval;
     }

     if (args.length() > 0) {
          command = args(0).string_value();
#if OCTAVE_MAJOR_VERSION < 6
          if (error_state) {
               return retval;
          }
#endif
     }

     if (args.length() > 1) {
          return_output = args(1).bool_value();
#if OCTAVE_MAJOR_VERSION < 6
          if (error_state) {
               return retval;
          }
#endif
     }

     if (args.length() > 2) {
          type = args(2).string_value();
#if OCTAVE_MAJOR_VERSION < 6
          if (error_state) {
               return retval;
          }
#endif
     } else {
          type = "sync";
     }

     if (nargout >= 2) {
          return_output = true;
     }

     if (type == "async") {
          async = true;
     } else if (type != "sync") {
          error("invalid argument: type = \"%s\"", type.c_str());
          return retval;
     }

     if (async && return_output) {
          error("invalid arguments: return_output = true && type = \"async\"");
          return retval;
     }

     {
          std::ostringstream cmdos;

          cmdos << "sh -c \"";

          for (char c:command) {
               switch (c) {
               case '"':
                    cmdos << '\\';
               }
               cmdos << c;
          }

          cmdos << "\"\0";

          command = cmdos.str();
     }

     SECURITY_ATTRIBUTES oProcAttr = {sizeof(SECURITY_ATTRIBUTES)};
     SECURITY_ATTRIBUTES oThreadAttr = {sizeof(SECURITY_ATTRIBUTES)};
     STARTUPINFO oStartupInfo = {sizeof(STARTUPINFO)};
     PROCESS_INFORMATION oProcessInfo = {0};

     HANDLE hInput = INVALID_HANDLE_VALUE;

     if (return_output) {
          SECURITY_ATTRIBUTES oPipeAttr = {sizeof(SECURITY_ATTRIBUTES)};
          oPipeAttr.bInheritHandle = TRUE;
          oStartupInfo.dwFlags = STARTF_USESTDHANDLES;

          if (!CreatePipe(&hInput, &oStartupInfo.hStdOutput, &oPipeAttr, 0)) {
               error("failed to create pipe for process \"%s\"", command.c_str());
               return retval;
          }

          SetHandleInformation(hInput, HANDLE_FLAG_INHERIT, 0);
          oStartupInfo.hStdInput = INVALID_HANDLE_VALUE;
          oStartupInfo.hStdError = oStartupInfo.hStdOutput;
     }

     BOOL bStatus = CreateProcess(NULL, &command.front(), &oProcAttr, &oThreadAttr, TRUE, 0, NULL, NULL, &oStartupInfo, &oProcessInfo);

     if (return_output) {
          CloseHandle(oStartupInfo.hStdOutput);
     }

     if (!bStatus) {
          error("failed to start process \"%s\"", command.c_str());
     } else {
          if (async) {
               retval.append(static_cast<double>(oProcessInfo.dwProcessId));
          } else {
               std::ostringstream output;

               if (return_output) {
                    std::vector<char> rgBuffer(1024);
                    DWORD dwBytes;

                    while (true) {
                         bStatus = ReadFile(hInput, &rgBuffer[0], rgBuffer.size(), &dwBytes, NULL);

                         if (!bStatus || !dwBytes) {
                              break;
                         }

                         output.write(&rgBuffer[0], dwBytes);
                    }
               }

               if (WAIT_OBJECT_0 != WaitForSingleObject(oProcessInfo.hProcess, INFINITE)) {
                    error("failed to wait for process \"%s\"", command.c_str());
               } else {
                    DWORD dwExitCode = -1;

                    if (!GetExitCodeProcess(oProcessInfo.hProcess, &dwExitCode)) {
                         error("failed to get exit code of process \"%s\"", command.c_str());
                    } else {
                         retval.append(static_cast<double>(dwExitCode));

                         if (return_output) {
                              retval.append(output.str());
                         }
                    }
               }
          }

          CloseHandle(oProcessInfo.hProcess);
          CloseHandle(oProcessInfo.hThread);
     }

     if (return_output) {
          CloseHandle(hInput);
     }

     return retval;
#else
     return OCTAVE__FEVAL("system", args, nargout);
#endif
}

/*
%!test
%! [status, output] = shell("ls -lhF .", true, "sync");
%! assert(status, 0);

%!test
%! [status] = shell("ls -lhF .", true);
%! assert(status, 0);

%!test
%! [status] = shell("ls -lhF . > /dev/null", false);
%! assert(status, 0);

%! [status] = shell("ls -lhF . > /dev/null");
%! assert(status, 0);

%!test
%! [status] = shell("ls -lhF . > /dev/null", false, "async");
%! assert(status > 0);

%!error
%! [status, output] = shell("ls -lhF .", true, "async");

%!error
%! [status, output] = shell("ls -lhF . > /dev/null", false, "async");

%!demo
%! [status, output] = shell("octave-config --version", true, "sync")
*/
