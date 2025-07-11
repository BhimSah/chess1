import 'package:flutter/material.dart';

enum ChessBoardTheme {
  classic,
  modern,
  wood,
  marble,
  blue,
  green,
  purple,
  dark,
}

class ChessBoardThemeData {
  final Color lightSquareColor;
  final Color darkSquareColor;
  final Color selectedSquareColor;
  final Color validMoveColor;
  final Color borderColor;
  final double borderWidth;
  final String name;

  const ChessBoardThemeData({
    required this.lightSquareColor,
    required this.darkSquareColor,
    required this.selectedSquareColor,
    required this.validMoveColor,
    required this.borderColor,
    required this.borderWidth,
    required this.name,
  });
}

class ChessBoard extends StatelessWidget {
  final List<List<ChessPiece?>> board;
  final ChessPiece? selectedPiece;
  final List<List<int>> validMoves;
  final Function(int, int) onSquareTapped;
  final ChessBoardTheme theme;
  final bool showCoordinates;
  final List<int>? lastMoveFrom; // [row, col]
  final List<int>? lastMoveTo;   // [row, col]

  const ChessBoard({
    super.key,
    required this.board,
    required this.selectedPiece,
    required this.validMoves,
    required this.onSquareTapped,
    this.theme = ChessBoardTheme.classic,
    this.showCoordinates = true,
    this.lastMoveFrom,
    this.lastMoveTo,
  });

  static ChessBoardThemeData getThemeData(ChessBoardTheme theme) {
    switch (theme) {
      case ChessBoardTheme.classic:
        return const ChessBoardThemeData(
          lightSquareColor: Color(0xFFF0D9B5),
          darkSquareColor: Color(0xFFB58863),
          selectedSquareColor: Color(0xFFF7EC58),
          validMoveColor: Color(0xFF7B61FF),
          borderColor: Color(0xFF8B4513),
          borderWidth: 3,
          name: 'Classic',
        );
      case ChessBoardTheme.modern:
        return const ChessBoardThemeData(
          lightSquareColor: Color(0xFFEEEED2),
          darkSquareColor: Color(0xFF769656),
          selectedSquareColor: Color(0xFFF7EC58),
          validMoveColor: Color(0xFF7B61FF),
          borderColor: Color(0xFF2C3E50),
          borderWidth: 2,
          name: 'Modern',
        );
      case ChessBoardTheme.wood:
        return const ChessBoardThemeData(
          lightSquareColor: Color(0xFFD2B48C),
          darkSquareColor: Color(0xFF8B4513),
          selectedSquareColor: Color(0xFFF4A460),
          validMoveColor: Color(0xFF32CD32),
          borderColor: Color(0xFF654321),
          borderWidth: 4,
          name: 'Wood',
        );
      case ChessBoardTheme.marble:
        return const ChessBoardThemeData(
          lightSquareColor: Color(0xFFF5F5DC),
          darkSquareColor: Color(0xFFC0C0C0),
          selectedSquareColor: Color(0xFF87CEEB),
          validMoveColor: Color(0xFF98FB98),
          borderColor: Color(0xFF696969),
          borderWidth: 3,
          name: 'Marble',
        );
      case ChessBoardTheme.blue:
        return const ChessBoardThemeData(
          lightSquareColor: Color(0xFFE6F3FF),
          darkSquareColor: Color(0xFF4A90E2),
          selectedSquareColor: Color(0xFFFFD700),
          validMoveColor: Color(0xFF00FF00),
          borderColor: Color(0xFF2E5BBA),
          borderWidth: 3,
          name: 'Blue',
        );
      case ChessBoardTheme.green:
        return const ChessBoardThemeData(
          lightSquareColor: Color(0xFFE8F5E8),
          darkSquareColor: Color(0xFF4CAF50),
          selectedSquareColor: Color(0xFFFFEB3B),
          validMoveColor: Color(0xFF2196F3),
          borderColor: Color(0xFF2E7D32),
          borderWidth: 3,
          name: 'Green',
        );
      case ChessBoardTheme.purple:
        return const ChessBoardThemeData(
          lightSquareColor: Color(0xFFF3E5F5),
          darkSquareColor: Color(0xFF9C27B0),
          selectedSquareColor: Color(0xFFFF9800),
          validMoveColor: Color(0xFF4CAF50),
          borderColor: Color(0xFF6A1B9A),
          borderWidth: 3,
          name: 'Purple',
        );
      case ChessBoardTheme.dark:
        return const ChessBoardThemeData(
          lightSquareColor: Color(0xFF424242),
          darkSquareColor: Color(0xFF212121),
          selectedSquareColor: Color(0xFFF57C00),
          validMoveColor: Color(0xFF4CAF50),
          borderColor: Color(0xFF000000),
          borderWidth: 2,
          name: 'Dark',
        );
    }
  }

  bool isValidMove(int row, int col) {
    return validMoves.any((move) => move[0] == row && move[1] == col);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = getThemeData(theme);
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: themeData.borderColor,
          width: themeData.borderWidth,
        ),
        borderRadius: BorderRadius.circular(16), // More rounded
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (showCoordinates) _buildCoordinateRow(themeData, true),
          Expanded(
            child: Row(
              children: [
                if (showCoordinates) _buildCoordinateColumn(themeData, true),
                Expanded(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                    ),
                    itemCount: 64,
                    itemBuilder: (context, index) {
                      int row = index ~/ 8;
                      int col = index % 8;
                      bool isLightSquare = (row + col) % 2 == 0;
                      bool isSelected = selectedPiece == board[row][col];
                      bool isMoveValid = isValidMove(row, col);
                      bool isLastMove = (lastMoveFrom != null && lastMoveTo != null &&
                        ((lastMoveFrom![0] == row && lastMoveFrom![1] == col) ||
                         (lastMoveTo![0] == row && lastMoveTo![1] == col)));

                      return GestureDetector(
                        onTap: () => onSquareTapped(row, col),
                        child: Stack(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? themeData.selectedSquareColor
                                    : isMoveValid
                                        ? themeData.validMoveColor.withOpacity(0.7)
                                        : isLastMove
                                            ? Colors.yellow.withOpacity(0.3)
                                            : isLightSquare
                                                ? themeData.lightSquareColor
                                                : themeData.darkSquareColor,
                                border: isSelected
                                    ? Border.all(
                                        color: Colors.orange,
                                        width: 3,
                                      )
                                    : null,
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.orange.withOpacity(0.4),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : [],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: null,
                            ),
                            if (isMoveValid && !isSelected)
                              Center(
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.greenAccent.withOpacity(0.7),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.greenAccent.withOpacity(0.5),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                child: board[row][col] != null
                                    ? ChessPieceWidget(
                                        key: ValueKey('${row}_${col}_${board[row][col]!.type}_${board[row][col]!.isWhite}'),
                                        piece: board[row][col]!,
                                        isSelected: isSelected,
                                        isValidMove: isMoveValid,
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (showCoordinates) _buildCoordinateColumn(themeData, false),
              ],
            ),
          ),
          if (showCoordinates) _buildCoordinateRow(themeData, false),
        ],
      ),
    );
  }

  Widget _buildCoordinateRow(ChessBoardThemeData themeData, bool isTop) {
    return Container(
      height: 20,
      child: Row(
        children: [
          if (showCoordinates) 
            SizedBox(width: 20), // Space for vertical coordinates
          ...List.generate(8, (index) {
            int col = isTop ? index : 7 - index;
            return Expanded(
              child: Center(
                child: Text(
                  String.fromCharCode(97 + col), // a-h
                  style: TextStyle(
                    color: themeData.borderColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }),
          if (showCoordinates) 
            SizedBox(width: 20), // Space for vertical coordinates
        ],
      ),
    );
  }

  Widget _buildCoordinateColumn(ChessBoardThemeData themeData, bool isLeft) {
    return Container(
      width: 20,
      child: Column(
        children: List.generate(8, (index) {
          int row = isLeft ? 7 - index : index;
          return Expanded(
            child: Center(
              child: Text(
                '${row + 1}',
                style: TextStyle(
                  color: themeData.borderColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class ChessPiece {
  final PieceType type;
  final bool isWhite;

  ChessPiece({required this.type, required this.isWhite});
}

enum PieceType {
  pawn,
  rook,
  knight,
  bishop,
  queen,
  king,
}

class ChessPieceWidget extends StatelessWidget {
  final ChessPiece piece;
  final bool isSelected;
  final bool isValidMove;

  const ChessPieceWidget({super.key, required this.piece, this.isSelected = false, this.isValidMove = false});

  @override
  Widget build(BuildContext context) {
    String symbol = _getPieceSymbol();
    Color color = piece.isWhite ? Colors.white : Colors.black;
    double scale = isSelected ? 1.2 : 1.0;
    List<Shadow> shadow = [
      Shadow(
        offset: const Offset(1, 1),
        blurRadius: 2,
        color: Colors.grey.withOpacity(0.5),
      ),
    ];
    if (isSelected) {
      shadow.add(
        Shadow(
          offset: const Offset(0, 0),
          blurRadius: 8,
          color: Colors.orange.withOpacity(0.7),
        ),
      );
    } else if (isValidMove) {
      shadow.add(
        Shadow(
          offset: const Offset(0, 0),
          blurRadius: 8,
          color: Colors.greenAccent.withOpacity(0.7),
        ),
      );
    }
    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 200),
      child: Text(
        symbol,
        style: TextStyle(
          fontSize: 36,
          color: color,
          fontWeight: FontWeight.bold,
          shadows: shadow,
        ),
      ),
    );
  }

  String _getPieceSymbol() {
    switch (piece.type) {
      case PieceType.king:
        return piece.isWhite ? '♔' : '♚';
      case PieceType.queen:
        return piece.isWhite ? '♕' : '♛';
      case PieceType.rook:
        return piece.isWhite ? '♖' : '♜';
      case PieceType.bishop:
        return piece.isWhite ? '♗' : '♝';
      case PieceType.knight:
        return piece.isWhite ? '♘' : '♞';
      case PieceType.pawn:
        return piece.isWhite ? '♙' : '♟';
    }
  }
}

class ThemeSelectionDialog extends StatefulWidget {
  final ChessBoardTheme currentTheme;
  final Function(ChessBoardTheme) onThemeChanged;

  const ThemeSelectionDialog({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  State<ThemeSelectionDialog> createState() => _ThemeSelectionDialogState();
}

class _ThemeSelectionDialogState extends State<ThemeSelectionDialog> {
  late ChessBoardTheme selectedTheme;

  @override
  void initState() {
    super.initState();
    selectedTheme = widget.currentTheme;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Board Theme'),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: ChessBoardTheme.values.length,
          itemBuilder: (context, index) {
            final theme = ChessBoardTheme.values[index];
            final themeData = ChessBoard.getThemeData(theme);
            final isSelected = selectedTheme == theme;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedTheme = theme;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey,
                    width: isSelected ? 3 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Mini board preview
                    Container(
                      width: 40,
                      height: 40,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                        ),
                        itemCount: 16,
                        itemBuilder: (context, index) {
                          int row = index ~/ 4;
                          int col = index % 4;
                          bool isLightSquare = (row + col) % 2 == 0;
                          
                          return Container(
                            color: isLightSquare
                                ? themeData.lightSquareColor
                                : themeData.darkSquareColor,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      themeData.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.blue : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onThemeChanged(selectedTheme);
            Navigator.pop(context);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
} 