import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:maslow_agents/presentation/agent_flows/agents_data_response.dart';

class CollapsibleList extends StatefulWidget {
  final List<AgentReasoning> agentReasoningList;
  final bool isAgentLoading;

  CollapsibleList({
    required this.agentReasoningList,
    this.isAgentLoading = false,
  });

  @override
  _CollapsibleListState createState() => _CollapsibleListState();
}

class _CollapsibleListState extends State<CollapsibleList> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, bool> _expandedItems = {};

  @override
  void initState() {
    super.initState();
    // Ensure the last item is expanded by default if it's not already in _expandedItems
    if (widget.agentReasoningList.isNotEmpty) {
      _expandedItems[widget.agentReasoningList.length - 1] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.agentReasoningList.length + (widget.isAgentLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < widget.agentReasoningList.length) {
          var reasoning = widget.agentReasoningList[index];
          return _subtasks(index, reasoning);
        } else if (widget.isAgentLoading) {
          return _loadingIndicator();
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _subtasks(int index, AgentReasoning reasoning) {
    // Check if the current index is expanded
    final isExpanded = _expandedItems[index] ?? (index == widget.agentReasoningList.length - 1 ? true : false);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(50),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                reasoning.agentName,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 20,
                  color: Colors.black87,
                ),
                onPressed: () {
                  setState(() {
                    _expandedItems[index] = !isExpanded;
                  });
                },
              ),
            ],
          ),
          if (isExpanded) ...[
            const SizedBox(height: 8),
            Divider(color: Colors.grey.withAlpha(150)),
            const SizedBox(height: 8),
            reasoning.messages?.isNotEmpty == true
                ? Column(
              children: List.generate(reasoning.messages?.length ?? 0, (msgIndex) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: MarkdownBody(
                    data: reasoning.messages![msgIndex],
                  ),
                );
              }),
            )
                : Text(
              reasoning.instructions?.isEmpty == true
                  ? "Finished"
                  : reasoning.instructions!,
              style: const TextStyle(color: Colors.black87, fontSize: 16),
            ),
          ] else
            const SizedBox.shrink(), // Optionally show a placeholder when collapsed
        ],
      ),
    );
  }

  Widget _loadingIndicator() {
    return Center(child: CircularProgressIndicator());
  }
}
