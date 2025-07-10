import 'package:flutter/material.dart';
import 'dart:math';


class User {
  final String username;
  final String email;
  final int gamesplayed;
  final int gameswon;
  final int gameslost;

  User({required this.username, required this.email, this.gamesplayed = 0, 
  this.gameswon = 0, this.gameslost = 0});
}
void main() {
  runApp(const ChessApp());
}

enum GameMode {
  humanVsHuman,
  humanVsAI,
}

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen ({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  // Simple user storage (in real app, use proper database)
  static final Map<String, User> _users = {
    'demo@example.com': User(
      username: 'demo',
      email: 'demo@example.com',
      gamesplayed: 15,
      gameswon: 8,
      gameslost: 7,
    ),
  };

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call delay
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isLoading = false;
        });

        if (_isLogin) {
          _handleLogin();
        } else {
          _handleRegister();
        }
      });
    }
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_users.containsKey(email) && password == 'password') {
      // Navigate to game mode selection with user data
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GameModeSelection(user: _users[email]!),
        ),
      );
    } else {
      _showErrorDialog('Invalid email or password. Try demo@example.com / password');
    }
  }

  void _handleRegister() {
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (_users.containsKey(email)) {
      _showErrorDialog('User already exists');
      return;
    }

    if (password.length < 6) {
      _showErrorDialog('Password must be at least 6 characters');
      return;
    }

    // Create new user
    final newUser = User(username: username, email: email);
    _users[email] = newUser;

    // Navigate to game mode selection
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GameModeSelection(user: newUser),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Title
                  Icon(
                    Icons.sports_esports,
                    size: 80,
                    color: Colors.brown[700],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chess Game',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin ? 'Welcome back!' : 'Create your account',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.brown[600],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Username field (only for register)
                  if (!_isLogin) ...[
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (!_isLogin && value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _isLogin ? 'Login' : 'Register',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Toggle between login and register
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        _emailController.clear();
                        _passwordController.clear();
                        _usernameController.clear();
                      });
                    },
                    child: Text(
                      _isLogin
                          ? 'Don\'t have an account? Register'
                          : 'Already have an account? Login',
                      style: TextStyle(color: Colors.brown[600]),
                    ),
                  ),

                  // Demo credentials
                  if (_isLogin) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.brown[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.brown[200]!),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Demo Credentials:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.brown[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Email: demo@example.com\nPassword: password',
                            style: TextStyle(color: Colors.brown[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GameModeSelection extends StatelessWidget {
  final User user;
  
  const GameModeSelection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Chess Game', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // User info section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.brown[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.brown[200]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.brown[700],
                      child: Text(
                        user.username[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${user.username}!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown[700],
                            ),
                          ),
                          Text(
                            user.email,
                            style: TextStyle(
                              color: Colors.brown[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Games', user.gamesplayed.toString()),
                    _buildStatItem('Wins', user.gameswon.toString()),
                    _buildStatItem('Losses', user.gameslost.toString()),
                    _buildStatItem('Win Rate', 
                      user.gamesplayed > 0 
                        ? '${((user.gameswon / user.gamesplayed) * 100).round()}%'
                        : '0%'
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Game mode selection
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Select Game Mode',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildGameModeButton(
                    context,
                    'Human vs Human',
                    'Play against another human player',
                    Icons.people,
                    GameMode.humanVsHuman,
                  ),
                  const SizedBox(height: 20),
                  _buildGameModeButton(
                    context,
                    'Human vs AI',
                    'Play against the computer',
                    Icons.computer,
                    GameMode.humanVsAI,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameModeButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    GameMode gameMode,
  ) {
    return Container(
      width: 300,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChessGame(gameMode: gameMode, user: user),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown[50],
          foregroundColor: Colors.brown[700],
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.brown[300]!, width: 2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.brown[600]),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.brown[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.brown[700],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.brown[600],
          ),
        ),
      ],
    );
  }
}

class ChessGame extends StatefulWidget {
  final GameMode gameMode;
  final User user;
  
  const ChessGame({super.key, required this.gameMode, required this.user});

  @override
  State<ChessGame> createState() => _ChessGameState();
}

class _ChessGameState extends State<ChessGame> {
  late List<List<ChessPiece?>> board;
  ChessPiece? selectedPiece;
  List<List<int>> validMoves = [];
  bool isWhiteTurn = true;
  bool gameOver = false;
  String gameStatus = 'White\'s turn';
  bool isAITurn = false;
  bool isCheck = false;
  bool isCheckmate = false;

  @override
  void initState() {
    super.initState();
    initializeBoard();
  }

  void initializeBoard() {
    board = List.generate(8, (index) => List.filled(8, null));
    
    // Set up pawns
    for (int i = 0; i < 8; i++) {
      board[1][i] = ChessPiece(type: PieceType.pawn, isWhite: false);
      board[6][i] = ChessPiece(type: PieceType.pawn, isWhite: true);
    }

    // Set up other pieces
    final pieceOrder = [
      PieceType.rook, PieceType.knight, PieceType.bishop, PieceType.queen,
      PieceType.king, PieceType.bishop, PieceType.knight, PieceType.rook
    ];

    for (int i = 0; i < 8; i++) {
      board[0][i] = ChessPiece(type: pieceOrder[i], isWhite: false);
      board[7][i] = ChessPiece(type: pieceOrder[i], isWhite: true);
    }
  }

  void selectPiece(int row, int col) {
    if (gameOver || isAITurn) return;
    
    final piece = board[row][col];
    if (piece != null && piece.isWhite == isWhiteTurn) {
      setState(() {
        selectedPiece = piece;
        validMoves = getValidMovesWithCheckValidation(row, col);
      });
    } else if (selectedPiece != null && isValidMove(row, col)) {
      movePiece(row, col);
    } else {
      setState(() {
        selectedPiece = null;
        validMoves = [];
      });
    }
  }

  bool isValidMove(int row, int col) {
    return validMoves.any((move) => move[0] == row && move[1] == col);
  }

  void movePiece(int toRow, int toCol) {
    // Find the selected piece's current position
    int fromRow = -1, fromCol = -1;
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] == selectedPiece) {
          fromRow = i;
          fromCol = j;
          break;
        }
      }
      if (fromRow != -1) break;
    }

    if (fromRow == -1) return;

    // Move the piece
    board[toRow][toCol] = selectedPiece;
    board[fromRow][fromCol] = null;

    // Check for pawn promotion
    if (selectedPiece!.type == PieceType.pawn) {
      if ((selectedPiece!.isWhite && toRow == 0) || (!selectedPiece!.isWhite && toRow == 7)) {
        board[toRow][toCol] = ChessPiece(type: PieceType.queen, isWhite: selectedPiece!.isWhite);
      }
    }

    // Check for check and checkmate after the move
    bool nextPlayerInCheck = isKingInCheck(!isWhiteTurn);
    bool nextPlayerInCheckmate = isInCheckmate(!isWhiteTurn);
    
    setState(() {
      selectedPiece = null;
      validMoves = [];
      isWhiteTurn = !isWhiteTurn;
      isCheck = nextPlayerInCheck;
      isCheckmate = nextPlayerInCheckmate;
      
      if (nextPlayerInCheckmate) {
        gameOver = true;
        gameStatus = '${isWhiteTurn ? 'Black' : 'White'} wins by checkmate!';
        _updateGameStats(isWhiteTurn);
      } else if (nextPlayerInCheck) {
        gameStatus = '${isWhiteTurn ? 'Black' : 'White'} is in check!';
      } else {
        gameStatus = '${isWhiteTurn ? 'White' : 'Black'}\'s turn';
      }
    });

    // Check if it's AI's turn
    if (widget.gameMode == GameMode.humanVsAI && !isWhiteTurn && !gameOver) {
      _makeAIMove();
    }
  }

  void _makeAIMove() {
    setState(() {
      isAITurn = true;
      gameStatus = 'AI is thinking...';
    });

    // Add a small delay to make AI moves visible
    Future.delayed(const Duration(milliseconds: 500), () {
      final aiMove = _getBestMove();
      if (aiMove != null) {
        final fromRow = aiMove[0];
        final fromCol = aiMove[1];
        final toRow = aiMove[2];
        final toCol = aiMove[3];

        // Move the AI piece
        final piece = board[fromRow][fromCol];
        board[toRow][toCol] = piece;
        board[fromRow][fromCol] = null;

        // Check for pawn promotion
        if (piece!.type == PieceType.pawn && toRow == 7) {
          board[toRow][toCol] = ChessPiece(type: PieceType.queen, isWhite: piece.isWhite);
        }

        // Check for check and checkmate after AI move
        bool nextPlayerInCheck = isKingInCheck(true);
        bool nextPlayerInCheckmate = isInCheckmate(true);
        
        setState(() {
          isWhiteTurn = true;
          isAITurn = false;
          isCheck = nextPlayerInCheck;
          isCheckmate = nextPlayerInCheckmate;
          
          if (nextPlayerInCheckmate) {
            gameOver = true;
            gameStatus = 'Black wins by checkmate!';
            _updateGameStats(false);
          } else if (nextPlayerInCheck) {
            gameStatus = 'White is in check!';
          } else {
            gameStatus = 'White\'s turn';
          }
        });
      }
    });
  }

  List<int>? _getBestMove() {
    List<List<int>> allMoves = [];
    
    // Find all possible moves for AI (black pieces)
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && !piece.isWhite) {
          final moves = getValidMovesWithCheckValidation(row, col);
          for (final move in moves) {
            allMoves.add([row, col, move[0], move[1]]);
          }
        }
      }
    }

    if (allMoves.isEmpty) return null;

    // Simple AI: prioritize captures and center control
    List<int> bestMove = allMoves[0];
    int bestScore = -1000;

    for (final move in allMoves) {
      int score = _evaluateMove(move);
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove;
  }

  int _evaluateMove(List<int> move) {
    int score = 0;
    final fromRow = move[0];
    final fromCol = move[1];
    final toRow = move[2];
    final toCol = move[3];
    final piece = board[fromRow][fromCol];
    final targetPiece = board[toRow][toCol];

    // Capture bonus
    if (targetPiece != null) {
      score += _getPieceValue(targetPiece.type) * 10;
    }

    // Center control bonus
    if (toRow >= 3 && toRow <= 4 && toCol >= 3 && toCol <= 4) {
      score += 2;
    }

    // Pawn advancement bonus
    if (piece!.type == PieceType.pawn) {
      score += (7 - toRow); // Closer to promotion = higher score
    }

    // Random factor to avoid predictable moves
    score += Random().nextInt(5);

    return score;
  }

  int _getPieceValue(PieceType type) {
    switch (type) {
      case PieceType.pawn:
        return 1;
      case PieceType.knight:
      case PieceType.bishop:
        return 3;
      case PieceType.rook:
        return 5;
      case PieceType.queen:
        return 9;
      case PieceType.king:
        return 100;
    }
  }

  List<List<int>> getValidMoves(int row, int col) {
    final piece = board[row][col];
    if (piece == null) return [];

    List<List<int>> moves = [];
    
    switch (piece.type) {
      case PieceType.pawn:
        moves = getPawnMoves(row, col, piece.isWhite);
        break;
      case PieceType.rook:
        moves = getRookMoves(row, col, piece.isWhite);
        break;
      case PieceType.knight:
        moves = getKnightMoves(row, col, piece.isWhite);
        break;
      case PieceType.bishop:
        moves = getBishopMoves(row, col, piece.isWhite);
        break;
      case PieceType.queen:
        moves = getQueenMoves(row, col, piece.isWhite);
        break;
      case PieceType.king:
        moves = getKingMoves(row, col, piece.isWhite);
        break;
    }

    return moves;
  }

  // Check if a king is in check
  bool isKingInCheck(bool isWhiteKing) {
    // Find the king's position
    int kingRow = -1, kingCol = -1;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.type == PieceType.king && piece.isWhite == isWhiteKing) {
          kingRow = row;
          kingCol = col;
          break;
        }
      }
      if (kingRow != -1) break;
    }

    if (kingRow == -1) return false; // King not found

    // Check if any opponent piece can attack the king
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.isWhite != isWhiteKing) {
          // Get all possible moves for this piece
          List<List<int>> moves = [];
          switch (piece.type) {
            case PieceType.pawn:
              moves = getPawnMoves(row, col, piece.isWhite);
              break;
            case PieceType.rook:
              moves = getRookMoves(row, col, piece.isWhite);
              break;
            case PieceType.knight:
              moves = getKnightMoves(row, col, piece.isWhite);
              break;
            case PieceType.bishop:
              moves = getBishopMoves(row, col, piece.isWhite);
              break;
            case PieceType.queen:
              moves = getQueenMoves(row, col, piece.isWhite);
              break;
            case PieceType.king:
              moves = getKingMoves(row, col, piece.isWhite);
              break;
          }
          
          // Check if any move can capture the king
          for (final move in moves) {
            if (move[0] == kingRow && move[1] == kingCol) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  // Check if a move would put or leave the king in check
  bool wouldMoveCauseCheck(int fromRow, int fromCol, int toRow, int toCol, bool isWhite) {
    // Temporarily make the move
    final originalPiece = board[toRow][toCol];
    final movingPiece = board[fromRow][fromCol];
    
    board[toRow][toCol] = movingPiece;
    board[fromRow][fromCol] = null;
    
    // Check if the king is in check after the move
    bool inCheck = isKingInCheck(isWhite);
    
    // Undo the move
    board[fromRow][fromCol] = movingPiece;
    board[toRow][toCol] = originalPiece;
    
    return inCheck;
  }

  // Get valid moves that don't put the king in check
  List<List<int>> getValidMovesWithCheckValidation(int row, int col) {
    final piece = board[row][col];
    if (piece == null) return [];

    List<List<int>> allMoves = getValidMoves(row, col);
    List<List<int>> validMoves = [];

    for (final move in allMoves) {
      if (!wouldMoveCauseCheck(row, col, move[0], move[1], piece.isWhite)) {
        validMoves.add(move);
      }
    }

    return validMoves;
  }

  // Check if the current player is in checkmate
  bool isInCheckmate(bool isWhite) {
    if (!isKingInCheck(isWhite)) return false;

    // Check if any piece can make a move that gets out of check
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.isWhite == isWhite) {
          final validMoves = getValidMovesWithCheckValidation(row, col);
          if (validMoves.isNotEmpty) {
            return false; // Found a legal move
          }
        }
      }
    }
    return true; // No legal moves found
  }

  List<List<int>> getPawnMoves(int row, int col, bool isWhite) {
    List<List<int>> moves = [];
    int direction = isWhite ? -1 : 1;
    int startRow = isWhite ? 6 : 1;

    // Forward move
    if (row + direction >= 0 && row + direction < 8 && board[row + direction][col] == null) {
      moves.add([row + direction, col]);
      
      // Double move from starting position
      if (row == startRow && board[row + 2 * direction][col] == null) {
        moves.add([row + 2 * direction, col]);
      }
    }

    // Diagonal captures
    for (int dCol in [-1, 1]) {
      int newCol = col + dCol;
      if (newCol >= 0 && newCol < 8 && row + direction >= 0 && row + direction < 8) {
        final targetPiece = board[row + direction][newCol];
        if (targetPiece != null && targetPiece.isWhite != isWhite) {
          moves.add([row + direction, newCol]);
        }
      }
    }

    return moves;
  }

  List<List<int>> getRookMoves(int row, int col, bool isWhite) {
    List<List<int>> moves = [];
    final directions = [[-1, 0], [1, 0], [0, -1], [0, 1]];

    for (final direction in directions) {
      int newRow = row + direction[0];
      int newCol = col + direction[1];
      
      while (newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8) {
        final targetPiece = board[newRow][newCol];
        if (targetPiece == null) {
          moves.add([newRow, newCol]);
        } else {
          if (targetPiece.isWhite != isWhite) {
            moves.add([newRow, newCol]);
          }
          break;
        }
        newRow += direction[0];
        newCol += direction[1];
      }
    }

    return moves;
  }

  List<List<int>> getKnightMoves(int row, int col, bool isWhite) {
    List<List<int>> moves = [];
    final knightMoves = [
      [-2, -1], [-2, 1], [-1, -2], [-1, 2],
      [1, -2], [1, 2], [2, -1], [2, 1]
    ];

    for (final move in knightMoves) {
      int newRow = row + move[0];
      int newCol = col + move[1];
      
      if (newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8) {
        final targetPiece = board[newRow][newCol];
        if (targetPiece == null || targetPiece.isWhite != isWhite) {
          moves.add([newRow, newCol]);
        }
      }
    }

    return moves;
  }

  List<List<int>> getBishopMoves(int row, int col, bool isWhite) {
    List<List<int>> moves = [];
    final directions = [[-1, -1], [-1, 1], [1, -1], [1, 1]];

    for (final direction in directions) {
      int newRow = row + direction[0];
      int newCol = col + direction[1];
      
      while (newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8) {
        final targetPiece = board[newRow][newCol];
        if (targetPiece == null) {
          moves.add([newRow, newCol]);
        } else {
          if (targetPiece.isWhite != isWhite) {
            moves.add([newRow, newCol]);
          }
          break;
        }
        newRow += direction[0];
        newCol += direction[1];
      }
    }

    return moves;
  }

  List<List<int>> getQueenMoves(int row, int col, bool isWhite) {
    List<List<int>> moves = [];
    moves.addAll(getRookMoves(row, col, isWhite));
    moves.addAll(getBishopMoves(row, col, isWhite));
    return moves;
  }

  List<List<int>> getKingMoves(int row, int col, bool isWhite) {
    List<List<int>> moves = [];
    final directions = [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1], [0, 1],
      [1, -1], [1, 0], [1, 1]
    ];

    for (final direction in directions) {
      int newRow = row + direction[0];
      int newCol = col + direction[1];
      
      if (newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8) {
        final targetPiece = board[newRow][newCol];
        if (targetPiece == null || targetPiece.isWhite != isWhite) {
          moves.add([newRow, newCol]);
        }
      }
    }

    return moves;
  }

  void resetGame() {
    setState(() {
      initializeBoard();
      selectedPiece = null;
      validMoves = [];
      isWhiteTurn = true;
      gameOver = false;
      gameStatus = 'White\'s turn';
      isAITurn = false;
      isCheck = false;
      isCheckmate = false;
    });
  }

  void _updateGameStats(bool whiteWon) {
    // In a real app, you would save this to a database
    // For now, we'll just show a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Over!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              whiteWon ? 'White wins!' : 'Black wins!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Player: ${widget.user.username}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Game Mode: ${widget.gameMode == GameMode.humanVsAI ? 'vs AI' : 'vs Human'}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              resetGame();
            },
            child: const Text('New Game'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Back to Menu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.gameMode == GameMode.humanVsAI ? 'Chess vs AI' : 'Chess Game',
          style: const TextStyle(fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetGame,
            tooltip: 'New Game',
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back to Menu',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  gameStatus,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: gameOver ? Colors.red : (isCheck ? Colors.orange : Colors.brown[700]),
                  ),
                ),
                if (widget.gameMode == GameMode.humanVsAI)
                  Text(
                    isWhiteTurn ? 'Your turn (White)' : 'AI\'s turn (Black)',
                    style: TextStyle(
                      fontSize: 14,
                      color: isWhiteTurn ? Colors.blue[600] : Colors.red[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (selectedPiece != null)
                  Text(
                    'Selected: ${selectedPiece!.type.name} (${selectedPiece!.isWhite ? 'White' : 'Black'})',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                if (validMoves.isNotEmpty)
                  Text(
                    'Valid moves: ${validMoves.length}',
                    style: TextStyle(fontSize: 14, color: Colors.green[600]),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.brown[700]!, width: 3),
                  borderRadius: BorderRadius.circular(8),
                ),
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

                    return GestureDetector(
                      onTap: () {
                        print('Tapped: row=$row, col=$col, piece=${board[row][col]?.type.name}');
                        selectPiece(row, col);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.yellow[300]
                              : isMoveValid
                                  ? Colors.green[300]
                                  : isLightSquare
                                      ? Colors.brown[100]
                                      : Colors.brown[600],
                          border: isSelected
                              ? Border.all(color: Colors.orange, width: 3)
                              : null,
                        ),
                        child: Center(
                          child: board[row][col] != null
                              ? ChessPieceWidget(piece: board[row][col]!)
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
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

  const ChessPieceWidget({super.key, required this.piece});

  @override
  Widget build(BuildContext context) {
    String symbol = _getPieceSymbol();
    Color color = piece.isWhite ? Colors.white : Colors.black;
    
    return Text(
      symbol,
      style: TextStyle(
        fontSize: 32,
        color: color,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            offset: const Offset(1, 1),
            blurRadius: 2,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
        ],
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
