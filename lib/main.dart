import 'package:flutter/material.dart';
import 'dart:math';
import 'chessboard.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


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

enum AILevel { easy, medium, hard }

class GameModeSelection extends StatefulWidget {
  final User user;
  
  const GameModeSelection({super.key, required this.user});

  @override
  State<GameModeSelection> createState() => _GameModeSelectionState();
}

class _GameModeSelectionState extends State<GameModeSelection> {
  AILevel selectedAILevel = AILevel.medium;
  GameMode? selectedGameMode;

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
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GameHistoryScreen()),
              );
            },
            tooltip: 'Game History',
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
                        widget.user.username[0].toUpperCase(),
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
                            'Welcome, ${widget.user.username}!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown[700],
                            ),
                          ),
                          Text(
                            widget.user.email,
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
                    _buildStatItem('Games', widget.user.gamesplayed.toString()),
                    _buildStatItem('Wins', widget.user.gameswon.toString()),
                    _buildStatItem('Losses', widget.user.gameslost.toString()),
                    _buildStatItem('Win Rate', 
                      widget.user.gamesplayed > 0 
                        ? '${((widget.user.gameswon / widget.user.gamesplayed) * 100).round()}%'
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
                    aiLevel: selectedAILevel,
                  ),
                 if (selectedGameMode == GameMode.humanVsAI) ...[
                   const SizedBox(height: 16),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       const Text('AI Level: '),
                       DropdownButton<AILevel>(
                         value: selectedAILevel,
                         items: const [
                           DropdownMenuItem(
                             value: AILevel.easy,
                             child: Text('Easy'),
                           ),
                           DropdownMenuItem(
                             value: AILevel.medium,
                             child: Text('Medium'),
                           ),
                           DropdownMenuItem(
                             value: AILevel.hard,
                             child: Text('Hard'),
                           ),
                         ],
                         onChanged: (level) {
                           if (level != null) {
                             setState(() {
                               selectedAILevel = level;
                             });
                           }
                         },
                       ),
                     ],
                   ),
                 ],
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
    {AILevel? aiLevel},
  ) {
    return Container(
      width: 300,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedGameMode = gameMode;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChessGame(
                gameMode: gameMode,
                user: widget.user,
                aiLevel: aiLevel ?? AILevel.medium,
              ),
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
  final AILevel aiLevel;
  
  const ChessGame({super.key, required this.gameMode, required this.user, this.aiLevel = AILevel.medium});

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
  ChessBoardTheme currentTheme = ChessBoardTheme.classic;
  bool showCoordinates = true;
  List<int>? lastMoveFrom;
  List<int>? lastMoveTo;
  List<String> moveHistory = [];

  @override
  void initState() {
    super.initState();
    aiLevel = widget.aiLevel;
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

    // Track last move
    setState(() {
      lastMoveFrom = [fromRow, fromCol];
      lastMoveTo = [toRow, toCol];
      moveHistory.add(_moveToAlgebraic(fromRow, fromCol, toRow, toCol));
    });

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
        _saveGameHistory(isWhiteTurn ? 'White' : 'Black');
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

        // Track last move
        setState(() {
          lastMoveFrom = [fromRow, fromCol];
          lastMoveTo = [toRow, toCol];
          moveHistory.add(_moveToAlgebraic(fromRow, fromCol, toRow, toCol));
        });

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
            _saveGameHistory('Black');
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
    // Easy: random move
    if (aiLevel == AILevel.easy) {
      List<List<int>> allMoves = [];
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
      return allMoves[Random().nextInt(allMoves.length)];
    }
    // Medium: minimax depth 2, Hard: depth 4
    int depth = aiLevel == AILevel.hard ? 4 : 2;
    int bestScore = -99999;
    List<int>? bestMove;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && !piece.isWhite) {
          final moves = getValidMovesWithCheckValidation(row, col);
          for (final move in moves) {
            // Simulate move
            final captured = board[move[0]][move[1]];
            final fromPiece = board[row][col];
            board[move[0]][move[1]] = fromPiece;
            board[row][col] = null;
            // Pawn promotion
            bool promoted = false;
            if (fromPiece!.type == PieceType.pawn && move[0] == 7) {
              board[move[0]][move[1]] = ChessPiece(type: PieceType.queen, isWhite: false);
              promoted = true;
            }
            int score = _minimax(depth, true, -100000, 100000, 0);
            // Undo move
            board[row][col] = fromPiece;
            board[move[0]][move[1]] = captured;
            if (promoted) {
              // revert to pawn if promoted
              board[move[0]][move[1]] = captured;
            }
            if (score > bestScore) {
              bestScore = score;
              bestMove = [row, col, move[0], move[1]];
            }
          }
        }
      }
    }
    return bestMove;
  }

  // Minimax with alpha-beta pruning and mate-in-N scoring
  int _minimax(int depth, bool isWhiteTurn, int alpha, int beta, int ply) {
    if (depth == 0) {
      return aiLevel == AILevel.hard ? _evaluateBoardAdvanced() : _evaluateBoard();
    }
    if (isWhiteTurn) {
      int maxEval = -1000000;
      for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
          final piece = board[row][col];
          if (piece != null && piece.isWhite) {
            final moves = getValidMovesWithCheckValidation(row, col);
            for (final move in moves) {
              final captured = board[move[0]][move[1]];
              final fromPiece = board[row][col];
              board[move[0]][move[1]] = fromPiece;
              board[row][col] = null;
              // Pawn promotion
              bool promoted = false;
              if (fromPiece!.type == PieceType.pawn && move[0] == 0) {
                board[move[0]][move[1]] = ChessPiece(type: PieceType.queen, isWhite: true);
                promoted = true;
              }
              // Check for checkmate after move
              bool isMate = isInCheckmate(false);
              int eval;
              if (isMate) {
                eval = 1000000 - ply; // Sooner mate is better
              } else {
                eval = _minimax(depth - 1, false, alpha, beta, ply + 1);
              }
              board[row][col] = fromPiece;
              board[move[0]][move[1]] = captured;
              if (promoted) {
                board[move[0]][move[1]] = captured;
              }
              maxEval = maxEval > eval ? maxEval : eval;
              alpha = alpha > eval ? alpha : eval;
              if (beta <= alpha) break;
            }
          }
        }
      }
      return maxEval;
    } else {
      int minEval = 1000000;
      for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
          final piece = board[row][col];
          if (piece != null && !piece.isWhite) {
            final moves = getValidMovesWithCheckValidation(row, col);
            for (final move in moves) {
              final captured = board[move[0]][move[1]];
              final fromPiece = board[row][col];
              board[move[0]][move[1]] = fromPiece;
              board[row][col] = null;
              // Pawn promotion
              bool promoted = false;
              if (fromPiece!.type == PieceType.pawn && move[0] == 7) {
                board[move[0]][move[1]] = ChessPiece(type: PieceType.queen, isWhite: false);
                promoted = true;
              }
              // Check for checkmate after move
              bool isMate = isInCheckmate(true);
              int eval;
              if (isMate) {
                eval = -1000000 + ply; // Sooner mate is better
              } else {
                eval = _minimax(depth - 1, true, alpha, beta, ply + 1);
              }
              board[row][col] = fromPiece;
              board[move[0]][move[1]] = captured;
              if (promoted) {
                board[move[0]][move[1]] = captured;
              }
              minEval = minEval < eval ? minEval : eval;
              beta = beta < eval ? beta : eval;
              if (beta <= alpha) break;
            }
          }
        }
      }
      return minEval;
    }
  }

  // Board evaluation: material + piece-square tables
  int _evaluateBoard() {
    int score = 0;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null) {
          int value = _getPieceValue(piece.type);
          // Add simple piece-square bonus for pawns/knights/queens
          if (piece.type == PieceType.pawn) {
            value += piece.isWhite ? (6 - row) : (row - 1);
          } else if (piece.type == PieceType.knight) {
            value += [3, 4, 4, 5, 5, 4, 4, 3][col];
          } else if (piece.type == PieceType.queen) {
            value += 1;
          }
          score += piece.isWhite ? value : -value;
        }
      }
    }
    return score;
  }

  // Advanced evaluation for hard level: material, piece-square, king safety, mobility
  int _evaluateBoardAdvanced() {
    int score = 0;
    int whiteMobility = 0;
    int blackMobility = 0;
    int whiteCenter = 0;
    int blackCenter = 0;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null) {
          int value = _getPieceValue(piece.type);
          // Piece-square bonus
          if (piece.type == PieceType.pawn) {
            value += piece.isWhite ? (6 - row) : (row - 1);
          } else if (piece.type == PieceType.knight) {
            value += [3, 4, 4, 5, 5, 4, 4, 3][col];
          } else if (piece.type == PieceType.queen) {
            value += 1;
          }
          // King safety: bonus if king is castled (on g/h or b/c columns)
          if (piece.type == PieceType.king) {
            if (piece.isWhite && (col == 6 || col == 7 || col == 1 || col == 2)) value += 5;
            if (!piece.isWhite && (col == 6 || col == 7 || col == 1 || col == 2)) value -= 5;
          }
          // Center control bonus
          if (row >= 2 && row <= 5 && col >= 2 && col <= 5) {
            if (piece.isWhite) whiteCenter++;
            else blackCenter++;
          }
          score += piece.isWhite ? value : -value;
          // Mobility
          if (piece.isWhite) {
            whiteMobility += getValidMovesWithCheckValidation(row, col).length;
          } else {
            blackMobility += getValidMovesWithCheckValidation(row, col).length;
          }
        }
      }
    }
    score += (whiteMobility - blackMobility);
    score += 2 * (whiteCenter - blackCenter);
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
      lastMoveFrom = null;
      lastMoveTo = null;
      moveHistory.clear();
    });
  }

  void _showThemeSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => ThemeSelectionDialog(
        currentTheme: currentTheme,
        onThemeChanged: (theme) {
          setState(() {
            currentTheme = theme;
          });
        },
      ),
    );
  }

  void _toggleCoordinates() {
    setState(() {
      showCoordinates = !showCoordinates;
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

  String _moveToAlgebraic(int fromRow, int fromCol, int toRow, int toCol) {
    String colName(int col) => String.fromCharCode(97 + col); // a-h
    return '${colName(fromCol)}${8 - fromRow}${colName(toCol)}${8 - toRow}';
  }

  Future<void> _saveGameHistory(String winner) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList('game_history') ?? [];
    final entry = GameHistoryEntry(
      moves: List<String>.from(moveHistory),
      playerWhite: widget.user.username,
      playerBlack: widget.gameMode == GameMode.humanVsAI ? 'AI' : 'Player 2',
      result: winner,
      mode: widget.gameMode == GameMode.humanVsAI ? 'Human vs AI' : 'Human vs Human',
      date: DateTime.now(),
    );
    history.add(jsonEncode(entry.toJson()));
    await prefs.setStringList('game_history', history);
  }

  Future<List<GameHistoryEntry>> loadGameHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList('game_history') ?? [];
    return history.map((e) => GameHistoryEntry.fromJson(jsonDecode(e))).toList();
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
            icon: Icon(showCoordinates ? Icons.grid_4x4 : Icons.grid_3x3),
            onPressed: _toggleCoordinates,
            tooltip: 'Toggle Coordinates',
          ),
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: _showThemeSelectionDialog,
            tooltip: 'Change Theme',
          ),
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
              child: ChessBoard(
                board: board,
                selectedPiece: selectedPiece,
                validMoves: validMoves,
                onSquareTapped: (row, col) {
                  print('Tapped: row= [0m$row, col=$col, piece=${board[row][col]?.type.name}');
                  selectPiece(row, col);
                },
                theme: currentTheme,
                showCoordinates: showCoordinates,
                lastMoveFrom: lastMoveFrom,
                lastMoveTo: lastMoveTo,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Model for game history
class GameHistoryEntry {
  final List<String> moves;
  final String playerWhite;
  final String playerBlack;
  final String result; // 'White', 'Black', 'Draw'
  final String mode; // 'Human vs Human' or 'Human vs AI'
  final DateTime date;

  GameHistoryEntry({
    required this.moves,
    required this.playerWhite,
    required this.playerBlack,
    required this.result,
    required this.mode,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'moves': moves,
    'playerWhite': playerWhite,
    'playerBlack': playerBlack,
    'result': result,
    'mode': mode,
    'date': date.toIso8601String(),
  };

  static GameHistoryEntry fromJson(Map<String, dynamic> json) => GameHistoryEntry(
    moves: List<String>.from(json['moves'] ?? []),
    playerWhite: json['playerWhite'] ?? '',
    playerBlack: json['playerBlack'] ?? '',
    result: json['result'] ?? '',
    mode: json['mode'] ?? '',
    date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
  );
}

class GameHistoryScreen extends StatefulWidget {
  const GameHistoryScreen({super.key});

  @override
  State<GameHistoryScreen> createState() => _GameHistoryScreenState();
}

class _GameHistoryScreenState extends State<GameHistoryScreen> {
  late Future<List<GameHistoryEntry>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadHistory();
  }

  Future<List<GameHistoryEntry>> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList('game_history') ?? [];
    return history.map((e) => GameHistoryEntry.fromJson(jsonDecode(e))).toList().reversed.toList();
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('game_history');
    setState(() {
      _historyFuture = _loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game History'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear History'),
                  content: const Text('Are you sure you want to clear all game history?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await _clearHistory();
              }
            },
            tooltip: 'Clear History',
          ),
        ],
      ),
      body: FutureBuilder<List<GameHistoryEntry>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final history = snapshot.data ?? [];
          if (history.isEmpty) {
            return const Center(child: Text('No games played yet.'));
          }
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final entry = history[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${entry.mode}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '${entry.date.toLocal().toString().split(".")[0]}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('White: ${entry.playerWhite}'),
                      Text('Black: ${entry.playerBlack}'),
                      Text('Result: ${entry.result}'),
                      const SizedBox(height: 8),
                      Text('Moves: ${entry.moves.join(", ")}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


