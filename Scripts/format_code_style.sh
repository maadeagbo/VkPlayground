#!/usr/bin/env bash

## run::format_code:=Clang-format src folder in project

find src -name *.h -exec clang-format {} -i --style="{\
	BasedOnStyle: mozilla, IndentWidth: 4, AlignConsecutiveAssignments: \
	true, AlignConsecutiveDeclarations: true, AlignConsecutiveMacros: true}" \;
find src -name *.c -exec clang-format {} -i --style="{\
	BasedOnStyle: mozilla, IndentWidth: 4, AlignConsecutiveAssignments: \
	true, AlignConsecutiveDeclarations: true, AlignConsecutiveMacros: true}" \;
find src -name *.hpp -exec clang-format {} -i --style="{\
	BasedOnStyle: mozilla, IndentWidth: 4, AlignConsecutiveAssignments: \
	true, AlignConsecutiveDeclarations: true, AlignConsecutiveMacros: true}" \;
find src -name *.cpp -exec clang-format {} -i --style="{\
	BasedOnStyle: mozilla, IndentWidth: 4, AlignConsecutiveAssignments: \
	true, AlignConsecutiveDeclarations: true, AlignConsecutiveMacros: true}" \;
